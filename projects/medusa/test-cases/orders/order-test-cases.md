# Test Cases - Orders

**Module:** Orders
**Interfaces under test:** `POST /store/carts/{id}/complete`, `GET /store/orders/{id}`, `GET /store/orders`, `GET /admin/orders`
**Environment:** Local Medusa v2.19.0, `http://localhost:9000`
**Executed:** 2026-09-01 / 2026-09-02

| TC ID | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Priority | Test Type | Status |
|---|---|---|---|---|---|---|---|---|
| TC-ORDER-001 | Complete a fully-prepared cart into an order (end-to-end checkout) | Cart has a line item, email, shipping/billing address, a shipping method, and an authorized payment session | See `requirements/module-analysis.md` §5 for the exact sequence | 1. `POST /store/carts/{id}/complete` | `200 {"type":"order", "order": {...}}`; `display_id: 1`, `total: 30` (2×€10 item + €10 shipping), `email` matches the cart | High | Positive / End-to-End / Smoke | Pass |
| TC-ORDER-002 | Order fields (`status`, `payment_status`, `fulfillment_status`) are tracked independently and correctly after checkout | Order from TC-ORDER-001 exists | — | 1. `GET /admin/orders` as admin | `status: "pending"`, `payment_status: "authorized"`, `fulfillment_status: "not_fulfilled"` | High | Positive / Data Consistency | Pass |
| TC-ORDER-003 | Order total is the sum of item total and shipping total, with no silent discrepancy | Order from TC-ORDER-001 | — | 1. Compare `order.item_total` (20) + `order.shipping_total` (10) against `order.total` (30) | Values reconcile exactly | High | Positive / Financial Correctness | Pass |
| TC-ORDER-004 | Order data is consistent between the API and the database | Order from TC-ORDER-001 | — | 1. `SELECT * FROM "order" WHERE id = ...`<br>2. `SELECT * FROM order_cart WHERE order_id = ...` | Row exists with matching `email`, `currency_code`; `order_cart` links back to the exact `cart_id` used at checkout | High | Positive / Database | Pass (see `database-testing/database-test-cases.md` DB-ORDER-01) |
| TC-ORDER-005 | Re-submitting a completion request for an already-completed cart does not create a duplicate order | Cart from TC-ORDER-001, already completed | — | 1. `POST /store/carts/{id}/complete` a second time on the same cart | Same existing order (`order_01M1EV05...`, `display_id: 1`) is returned again; no second order is created | High | Edge Case / Idempotency | Pass — confirmed idempotent; a naive implementation could have created a duplicate order or errored, neither happened |
| TC-ORDER-006 | Retrieving a nonexistent order ID returns 404 | — | `order_INVALID_ID` | 1. `GET /admin/orders/order_INVALID_ID` (admin) | `404 {"type":"not_found","message":"Order id not found: order_INVALID_ID"}` | High | Negative | Pass |
| TC-ORDER-007 | `GET /store/orders/{id}` returns full order detail — including customer PII — to any caller holding only a publishable API key, with no proof of order ownership | A completed order exists; caller has a valid publishable key but **no** customer bearer token | — | 1. `GET /store/orders/{order_id}` with only `x-publishable-api-key`, no `Authorization` header | **Expected:** rejected, or at minimum scoped to a token proving the requester is the order's own customer/guest. | High | Security / Access Control | **Fail** — returns `200` with the complete order, including `email` and full `shipping_address` (name, street, city). Confirmed the same order is also returned using an **unrelated, authenticated customer's** bearer token — the endpoint performs no ownership check at all. See [BUG-04](../../bug-reports/BUG-04-order-access-control.md) | 
| TC-ORDER-008 | A registered customer's order-history listing correctly excludes orders placed under a different email | Guest order exists under `qa.tester+cart1@example.com`; registered customer is `qa.customer1@example.com` | Customer JWT for `qa.customer1@example.com` | 1. `GET /store/orders` with the customer's own token | `200`; `orders: []` — the unrelated guest order is not listed | High | Positive / Data Isolation | Pass (same evidence as TC-CUST-006; contrasts directly with TC-ORDER-007's finding — listing is scoped, but direct-by-ID retrieval is not) |
| TC-ORDER-009 | Admin can view and manage the order regardless of customer scoping | Admin JWT | — | 1. `GET /admin/orders/{order_id}` | `200`; full order detail returned, as expected for a merchant-facing role | High | Positive / Functional | Pass |
| TC-ORDER-010 | Order confirmation page renders correctly in-browser after checkout | Storefront reachable, checkout just completed | — | 1. Complete checkout in a browser<br>2. Observe the order confirmation page | Order number, items, and totals render correctly | Medium | UI | Blocked — no browser automation tool available in this environment |

## Notes

**TC-ORDER-007 is the finding that matters most out of this whole project.** To be clear about what actually got proven here: it's not just that guest orders are viewable without logging in (that part would be a fine, common pattern for an order-confirmation page). What got tested and confirmed is that a *different, logged-in customer's own valid token* was accepted for someone else's order without so much as a blink. There's no ownership check running at all. Full reasoning on severity and how exploitable this really is (order IDs are unguessable ULIDs, so it's not a walk-the-sequence problem) is in the bug report.

## Summary

| Result | Count |
|---|---|
| Pass | 8 |
| Fail | 1 |
| Blocked | 1 |
| **Total** | **10** |

Order creation, totals, idempotent completion, database consistency — all solid. The one real problem is BUG-04, on direct order retrieval.
