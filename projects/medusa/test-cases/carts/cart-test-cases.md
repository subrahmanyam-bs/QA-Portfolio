# Test Cases - Carts

**Module:** Carts
**Interfaces under test:** `POST /store/carts`, `GET /store/carts/{id}`, `POST /store/carts/{id}/line-items`, `POST /store/carts/{id}/line-items/{line_id}`, `DELETE /store/carts/{id}/line-items/{line_id}`
**Environment:** Local Medusa v2.19.0, `http://localhost:9000`, region "Europe" (EUR), variant `SHORTS-M` (€10)
**Executed:** 2026-09-01 / 2026-09-02

| TC ID | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Priority | Test Type | Status |
|---|---|---|---|---|---|---|---|---|
| TC-CART-001 | Create a new cart for a valid region | Valid publishable key | `region_id` for "Europe" | 1. `POST /store/carts` with `{"region_id": "..."}` | `200`; new `cart.id` returned, `currency_code: "eur"` | High | Positive / Smoke | Pass |
| TC-CART-002 | Add a valid line item to a cart | Cart exists | `variant_id` for SHORTS-M, `quantity: 2` | 1. `POST /store/carts/{id}/line-items` | `200`; item appears in `cart.items`, `unit_price: 10`, `cart.total: 20` | High | Positive / Functional | Pass |
| TC-CART-003 | Adding an item with a nonexistent `variant_id` is rejected | Cart exists | `variant_id: "variant_DOES_NOT_EXIST"` | 1. `POST /store/carts/{id}/line-items` | `400 {"type":"invalid_data","message":"Variants variant_DOES_NOT_EXIST do not exist or belong to a product that is not published"}` | High | Negative | Pass |
| TC-CART-004 | Quantity of exactly `1` (lower valid boundary) is accepted | Cart exists, empty | `quantity: 1` | 1. `POST /store/carts/{id}/line-items` with `quantity: 1` | `200`; item added with `quantity: 1` | High | Boundary | Pass |
| TC-CART-005 | Quantity of `0` is rejected on item creation | Cart exists, empty | `quantity: 0` | 1. `POST /store/carts/{id}/line-items` with `quantity: 0` | `400`, validation error naming `quantity` | High | Boundary | Pass — see note on the error message wording below |
| TC-CART-006 | Negative quantity is rejected on item creation | Cart exists, empty | `quantity: -5` | 1. `POST /store/carts/{id}/line-items` with `quantity: -5` | `400`, validation error naming `quantity` | High | Negative / Boundary | Pass |
| TC-CART-007 | Non-integer (decimal) quantity is silently rounded instead of rejected | Cart exists, empty | `quantity: 2.7` | 1. `POST /store/carts/{id}/line-items` with `quantity: 2.7` | **Expected:** rejected (`400`) — quantity should be a whole number of units. | High | Boundary / Data Validation | **Fail** — accepted with `200`; stored/returned `quantity: 3` (rounded). Confirmed again with `quantity: 2.2` → stored as `2`. See [BUG-01](../../bug-reports/BUG-01-decimal-quantity-rounded.md) |
| TC-CART-008 | Requesting a quantity larger than available inventory is rejected | Cart exists | `quantity: 999999` | 1. `POST /store/carts/{id}/line-items` with an unrealistic quantity | `400 {"code":"insufficient_inventory","type":"not_allowed","message":"Some variant does not have the required inventory"}` | High | Negative / Boundary | Pass |
| TC-CART-009 | Update an existing line item's quantity | Cart has 1 line item, `quantity: 2` | New `quantity: 5` | 1. `POST /store/carts/{id}/line-items/{line_id}` with `{"quantity": 5}` | `200`; `quantity: 5`, `total` recalculated to `50` | High | Positive / Functional | Pass |
| TC-CART-010 | Setting a line item's quantity to `0` via update removes the item | Cart has 1 line item | `{"quantity": 0}` | 1. `POST /store/carts/{id}/line-items/{line_id}` with `{"quantity": 0}` | Item is removed from the cart (`items: []`), cart total returns to `0` | Medium | Edge Case | Pass — noted design difference from TC-CART-005 (create rejects 0, update-to-0 removes); documented, not treated as a defect |
| TC-CART-011 | Explicitly removing a line item | Cart has 1 line item | — | 1. `DELETE /store/carts/{id}/line-items/{line_id}` | `200`; `deleted: true`; cart's `items` array no longer contains it, total recalculates to `0` | High | Positive / Functional | Pass |
| TC-CART-012 | Cart state persists across separate requests (server-side persistence) | Cart has 1 line item, `quantity: 5` | — | 1. `GET /store/carts/{id}` in a fresh request | `200`; returned cart still shows `quantity: 5` for the item | High | Positive / Persistence | Pass |
| TC-CART-013 | Retrieving a nonexistent cart ID | — | `cart_doesnotexist123` | 1. `GET /store/carts/cart_doesnotexist123` | `404 {"type":"not_found","message":"Cart with id 'cart_doesnotexist123' not found"}` | High | Negative | Pass |
| TC-CART-014 | Cart requires a valid publishable API key like all Store routes | — | No `x-publishable-api-key` header | 1. `POST /store/carts` with no publishable key | `400`, clear message naming the missing header | High | Negative / Security | Pass |
| TC-CART-015 | Cart persists across a simulated "browser refresh" (re-fetch by ID with no other state) | Cart with items exists | — | 1. `GET /store/carts/{id}` twice, several seconds apart, no other calls in between | Identical cart state returned both times | Medium | Edge Case | Pass — verified at the API level; genuine browser-refresh/localStorage behavior was not verified (no browser tool available) |
| TC-CART-016 | Adding the same variant twice merges into a single line item with combined quantity | Cart has 1 item, `quantity: 1`, of a given variant | Add the same `variant_id` again, `quantity: 1` | 1. `POST /store/carts/{id}/line-items` twice with the same `variant_id` | Single line item with `quantity: 2`, not two separate line items | Medium | Edge Case | Pass — confirmed during BUG-01 reproduction (see bug report) |

## Notes

**On the TC-CART-005/006 error text.** The message reads `"Invalid request: Value for field 'quantity' too small, expected at least: '0'"`. Read that twice — it says the minimum is `0`, but `0` is the exact value that just got rejected. The real floor is `1`. Just a wording bug in the message, the actual rejection is correct, so I logged it as an observation in `api-testing/api-test-cases.md` instead of opening a separate ticket for it.

## Summary

| Result | Count |
|---|---|
| Pass | 15 |
| Fail | 1 |
| **Total** | **16** |

The whole lifecycle — create, add, update, remove, retrieve — held together well. BUG-01 (decimal quantity getting rounded) is the one real gap here.
