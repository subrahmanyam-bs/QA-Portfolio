# BUG-01: Cart line-item quantity silently rounds non-integer values instead of rejecting them

| Field | Value |
|---|---|
| **Bug ID** | BUG-01 |
| **Title** | `POST /store/carts/{id}/line-items` accepts a decimal `quantity` and silently rounds it to the nearest integer |
| **Module** | Carts |
| **Environment** | Medusa v2.19.0, local instance, `http://localhost:9000`, Node v24.12.0, Windows 11 |
| **Preconditions** | A cart exists (`POST /store/carts` with a valid `region_id`); a valid `variant_id` and publishable API key are available |
| **Severity** | Low |
| **Priority** | Medium |
| **Reproducibility** | 100% (2 for 2, tried on two separate carts with two different decimal values) |
| **Status** | New |

## Steps to Reproduce
1. Create a new, empty cart: `POST /store/carts` with `{"region_id": "<europe_region_id>"}`.
2. Add a line item with a non-integer quantity: `POST /store/carts/{cart_id}/line-items`, body `{"variant_id": "<variant_id>", "quantity": 2.7}`.
3. Check `cart.items[0].quantity` and `cart.total` in the response.
4. Repeat on a fresh cart with `quantity: 2.2`.

## Test Data
- Variant: `variant_01M1ETAFKNS008R45DGXFWV7GE` (Medusa Shorts, size M, unit price €10)
- Quantities tried: `2.7`, `2.2`

## Expected Result
A non-whole-number `quantity` should be rejected with a `400` naming the field, the same way this endpoint already rejects `0` and negative values (`"Invalid request: Value for field 'quantity' too small..."`).

## Actual Result
Neither request is rejected. Both return `200`, and the value gets rounded to the nearest integer instead:
- `quantity: 2.7` comes back as `quantity: 3`, `cart.total: 30` (3 × €10)
- `quantity: 2.2` comes back as `quantity: 2`, `cart.total: 20` (2 × €10)

So it's real rounding, not truncation — the API just quietly does `Math.round()` on your input.

```
POST /store/carts/cart_01M1EV2N6BJH1GN77RS9PJ9YNN/line-items
{"variant_id":"variant_01M1ETAFKNS008R45DGXFWV7GE","quantity":2.7}

→ 200
"items":[{ ... "quantity": 3 ... }]
```

Anyone entering `2.7` expects 2.7, or an error, not to get charged for 3. There's no message anywhere in the response telling the caller their input got changed.

## Evidence
Raw request/response above and in `test-cases/carts/cart-test-cases.md` (TC-CART-007). Ran it twice with different decimals specifically to rule out a one-off fluke before writing this up.
