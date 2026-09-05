# BUG-04: `GET /store/orders/{id}` discloses full order details with no ownership check

| Field | Value |
|---|---|
| **Bug ID** | BUG-04 |
| **Title** | Order retrieval by ID doesn't check that the requester actually owns the order |
| **Module** | Orders / Access Control |
| **Environment** | Medusa v2.19.0, local instance, `http://localhost:9000` |
| **Preconditions** | A completed order exists (guest checkout, `qa.tester+cart1@example.com`); a second, unrelated registered customer exists (`qa.customer1@example.com`) |
| **Severity** | Medium |
| **Priority** | High |
| **Reproducibility** | 100%, tried under two different auth conditions |
| **Status** | New |

This is the one I'd push back on hardest before calling this environment production-ready.

## Steps to Reproduce

**No token at all:**
1. `GET /store/orders/{order_id}` with only `x-publishable-api-key`, no `Authorization` header.
2. Full order comes back.

**A different customer's own, valid token:**
1. Log in as `qa.customer1@example.com` — a real account that never placed this order.
2. `GET /store/orders/{order_id}` using that customer's token plus the publishable key.
3. Same order, still comes back in full.

## Test Data
- Target order: `order_01M1EV05DVMRATT14P97YMVSDH`, placed by guest `qa.tester+cart1@example.com`
- Unrelated authenticated customer used to probe it: `qa.customer1@example.com`

## Expected Result
This route should only hand back an order if the caller can prove some right to see it — a customer token whose `customer_id` matches the order, or a scoped token issued specifically for a guest order at checkout. A logged-in but otherwise unrelated customer shouldn't be able to pull up somebody else's order just by knowing the ID.

## Actual Result
Both requests return `200` with the whole order, including the customer's email and full shipping address (name, street, city, postal code):

```
GET /store/orders/order_01M1EV05DVMRATT14P97YMVSDH
Headers: x-publishable-api-key only

→ 200
{"order": {"email": "qa.tester+cart1@example.com",
           "shipping_address": {"first_name":"QA","last_name":"Tester","address_1":"123 Test Street", ...},
           ...full order...}}
```

```
GET /store/orders/order_01M1EV05DVMRATT14P97YMVSDH
Headers: x-publishable-api-key + Authorization: Bearer <qa.customer1's own token>

→ 200
{"order": {"email": "qa.tester+cart1@example.com", ...same full order...}}
```

Same response either way. That's the part that makes this a real defect and not just "guest orders are viewable without login" (which would be a defensible pattern on its own, for an order-confirmation page). There is no ownership check at all — a signed-in customer's own valid token gets treated identically to no token.

## Why I'm calling this Medium, not High
This is textbook broken object-level authorization: a publishable key (not a secret, it ships in every storefront's client-side JS) plus any order ID is enough to read someone's name, home address, and email. That alone would usually push me toward High.

What holds it at Medium is that Medusa order IDs are ULIDs (`order_` + a 26-character random string) — not sequential, not realistically guessable by brute force. So this isn't "walk through order IDs 1, 2, 3 and harvest everyone's address." It still leaks the moment an ID gets out through some other channel — a confirmation email, browser history, a `Referer` header on a third-party script embedded on the confirmation page, a support ticket. Those are all plausible in a real deployment, so "the ID is hard to guess" isn't a reason to leave the check out. Priority is High regardless of the Medium severity: this is a cheap fix, and I'd want the same pattern audited on any other guest-accessible resource keyed by ID before shipping.

## Evidence
Request/response pairs above, and `test-cases/orders/order-test-cases.md` (TC-ORDER-007).
