# API Testing - Medusa Store & Admin API

**Base URL:** `http://localhost:9000`
**Medusa version:** v2.19.0
**Executed against:** Local instance provisioned for this project (see `requirements/module-analysis.md`)
**Executed:** 2026-09-01 / 2026-09-02

This covers the Store API and Admin API endpoints I actually hit during this project. The contracts documented below are what I observed, not what the docs say should happen. The same requests are runnable from `postman/medusa-api-collection.json`.

## Authentication summary
- **Admin**: `POST /auth/user/emailpass` → `{ token }`. Send as `Authorization: Bearer <token>` on all `/admin/*` routes.
- **Customer**: `POST /auth/customer/emailpass` (login) or `POST /auth/customer/emailpass/register` (register) → `{ token }`. Send as `Authorization: Bearer <token>` on customer-scoped `/store/*` routes.
- **Store API (app identity)**: every `/store/*` route additionally requires `x-publishable-api-key: <key>`, obtained from `GET /admin/api-keys` (admin-authenticated).

---

## 1. Auth endpoints

### `POST /auth/user/emailpass` (Admin login)
| Scenario | Request | Expected | Actual |
|---|---|---|---|
| Valid credentials | `{"email","password"}` valid | `200`, JWT | `200`, JWT — **Pass** |
| Wrong password | valid email, wrong password | `401`, generic message | `401 {"type":"unauthorized","message":"Invalid email or password"}` — **Pass** |
| Nonexistent email | unregistered email | `401`, generic message (no enumeration) | Same generic message as wrong-password case — **Pass** |
| Missing `password` field | `{"email"}` only | `400`-class validation error | `401 {"type":"unauthorized","message":"Password should be a string"}` — **Pass (functionally)**, though `401` for a shape-of-request problem is a status-code quirk, see below |
| Empty body `{}` | `{}` | `400`-class validation error | Same `401 "Password should be a string"` as above — **Pass (functionally)** |

### `POST /auth/customer/emailpass/register` (Customer registration)
| Scenario | Request | Expected | Actual |
|---|---|---|---|
| Valid new email | valid email + password | `200`, JWT | `200`, JWT — **Pass** |
| Duplicate email | previously-registered email | `4xx`, rejected | `401 {"type":"unauthorized","message":"Identity with email already exists"}` — **Pass** |
| Missing password | `{"email"}` only | `400`-class error | `401 "Password should be a string"` — **Pass (functionally)**, same status-code note as above |
| **Invalid email format** | `email: "not-an-email"` | `400`-class validation error naming `email` | **`200`, valid JWT issued — Fail.** See [BUG-02](../bug-reports/BUG-02-invalid-email-accepted.md) |

### `POST /auth/customer/emailpass` (Customer login)
Same pattern as admin login: valid credentials → `200` + JWT; wrong password and nonexistent email both → `401` with the identical generic message `"Invalid email or password"` (no account-enumeration signal). **Pass** for all three.

---

## 2. Products (`/store/products`)

| Scenario | Method/Path | Auth | Expected status | Actual status | Result |
|---|---|---|---|---|---|
| List products | `GET /store/products` | publishable key | 200 | 200, `count: 4` | Pass |
| Product detail with variants + region price | `GET /store/products?limit=1&region_id={id}&fields=...,*variants.calculated_price` | publishable key | 200 | 200, correct SKUs and `calculated_amount: 10` in `eur` | Pass |
| Nonexistent product ID | `GET /store/products/prod_INVALID_ID_123` | publishable key | 404 | 404, clear message | Pass |
| Handle lookup | `GET /store/products?handle=shorts` | publishable key | 200 | 200, `count: 1` | Pass |
| Free-text search | `GET /store/products?q=Shorts` | publishable key | 200 | 200, matching result | Pass |
| Price requested with no `region_id` | `GET /store/products?...,*variants.calculated_price` (no region) | publishable key | 400, names missing context | 400 `"Missing required pricing context to calculate prices - region_id"` | Pass |
| Region passed as header instead of query param | `x-region-id` header, no query param | publishable key | Documents actual contract | Header ignored; same 400 as above | Pass — confirms `region_id` **must** be a query parameter |
| `limit=0` | `GET /store/products?limit=0` | publishable key | 200, empty array | 200, `products: []`, `count: 4` | Pass |
| `limit=-1` | `GET /store/products?limit=-1` | publishable key | 400 | **500 `unknown_error`** | **Fail** — [BUG-03](../bug-reports/BUG-03-negative-pagination-500.md) |
| `offset=-1` | `GET /store/products?offset=-1` | publishable key | 400 | **500 `unknown_error`** | **Fail** — [BUG-03](../bug-reports/BUG-03-negative-pagination-500.md) |
| No publishable key | `GET /store/products` | none | 400 | 400, names missing header | Pass |
| Invalid publishable key | `GET /store/products` | garbage key | 400 | 400 `"A valid publishable key is required..."` | Pass |

---

## 3. Carts (`/store/carts`)

| Scenario | Method/Path | Expected status | Actual status | Result |
|---|---|---|---|---|
| Create cart | `POST /store/carts` `{region_id}` | 200 | 200 | Pass |
| Add valid line item | `POST /store/carts/{id}/line-items` | 200 | 200, correct totals | Pass |
| Add item with invalid `variant_id` | same | 400 | 400, clear message | Pass |
| `quantity: 1` (lower boundary) | same | 200 | 200 | Pass |
| `quantity: 0` | same | 400 | 400 (message wording issue — see note below) | Pass (functionally) |
| `quantity: -5` | same | 400 | 400 | Pass |
| `quantity: 2.7` / `2.2` (decimal) | same | 400 | **200, silently rounded to 3 / 2** | **Fail** — [BUG-01](../bug-reports/BUG-01-decimal-quantity-rounded.md) |
| `quantity: 999999` (exceeds stock) | same | 400, insufficient inventory | 400 `"insufficient_inventory"` | Pass |
| Update item quantity | `POST /store/carts/{id}/line-items/{line_id}` | 200 | 200, recalculated total | Pass |
| Update quantity to `0` | same | Removes item (design choice, differs from create-time rejection) | Item removed, cart total 0 | Pass, seems intentional |
| Remove item | `DELETE /store/carts/{id}/line-items/{line_id}` | 200 | 200, `deleted: true` | Pass |
| Retrieve cart (persistence) | `GET /store/carts/{id}` | 200, state matches prior writes | 200, matches | Pass |
| Nonexistent cart | `GET /store/carts/cart_doesnotexist` | 404 | 404, clear message | Pass |
| No publishable key | `POST /store/carts` | 400 | 400 | Pass |
| Invalid `region_id` on create | `POST /store/carts` `{region_id: "reg_INVALID_XYZ"}` | 4xx | 404 `"No regions found"` | Pass (message slightly misleading — implies zero regions exist, not "no match" — noted, not filed) |

**On the quantity 0/-5 message:** it reads `"Invalid request: Value for field 'quantity' too small, expected at least: '0'"`, which says the minimum is `0` while rejecting `0`. The rejection itself is correct, just the wording is off, so this isn't its own bug ticket, just flagging it here.

---

## 4. Customers (`/store/customers`)

| Scenario | Method/Path | Auth | Expected | Actual | Result |
|---|---|---|---|---|---|
| Create profile (post-registration) | `POST /store/customers` | customer JWT | 200 | 200, `has_account: true` | Pass |
| Create profile, no bearer token | same | publishable key only | 401 | 401 `Unauthorized` | Pass |
| Get own profile | `GET /store/customers/me` | customer JWT | 200 | 200, matches account | Pass |
| Get own profile, no token | same | publishable key only | 401 | 401 | Pass |
| Update profile field | `POST /store/customers/me` | customer JWT | 200 | 200, field updated | Pass |
| Add address (full) | `POST /store/customers/me/addresses` | customer JWT | 200 | 200, address stored | Pass |
| Add address (missing city/country/postal) | same | customer JWT | (no strict expectation, exploring the contract) | 200, saved with those fields `null` | Pass — reads like deferred validation is intentional, see `test-cases/customers/customer-test-cases.md` for the reasoning |
| Fetch another customer's profile by ID | `GET /store/customers/{other_id}` | own customer JWT | No such route should exist / be forbidden | Plain framework `404 Cannot GET ...` — route doesn't exist | Pass — good access-control design |
| Own order history | `GET /store/orders` | customer JWT | 200, scoped to own orders only | 200, correctly excludes unrelated guest order | Pass |

---

## 5. Regions (`/store/regions`)

| Scenario | Method/Path | Expected | Actual | Result |
|---|---|---|---|---|
| List regions | `GET /store/regions` | 200 | 200, 1 region ("Europe", `eur`, 7 countries) | Pass |
| Get region by valid ID | `GET /store/regions/{id}` | 200 | 200, full detail | Pass |
| Get region by invalid ID | `GET /store/regions/reg_INVALID` | 404 | 404, clear message | Pass |

---

## 6. Orders

| Scenario | Method/Path | Auth | Expected | Actual | Result |
|---|---|---|---|---|---|
| Complete cart → order | `POST /store/carts/{id}/complete` | publishable key | 200, `{type: "order", order}` | 200, order created, correct total | Pass |
| Re-complete same cart | same | publishable key | Idempotent — same order returned | Same order returned, no duplicate | Pass |
| Admin: get order by invalid ID | `GET /admin/orders/order_INVALID_ID` | admin JWT | 404 | 404, clear message | Pass |
| Admin: list orders | `GET /admin/orders` | admin JWT | 200, order data present and consistent | 200 | Pass |
| **Store: get order by ID, no bearer token** | `GET /store/orders/{id}` | publishable key only | Should require ownership proof | **200, full order + PII returned** | **Fail** — [BUG-04](../bug-reports/BUG-04-order-access-control.md) |
| **Store: get order by ID, unrelated customer's token** | same | unrelated customer JWT | Should be forbidden | **200, full order + PII returned** | **Fail** — same as above, [BUG-04](../bug-reports/BUG-04-order-access-control.md) |

---

## Business validation checks performed
- Cart total = sum of line items + shipping, checked arithmetically against the API response (TC-ORDER-003).
- An order created from a cart preserves the exact `cart_id`, `email`, and item data, cross-checked directly against the database in `database-testing/database-test-cases.md`.
- Currency on pricing always matches the cart/order's region currency, every time I checked it.
- A guest checkout email and a separately-registered customer can share the same email without conflict, since the unique constraint is `(email, has_account)`, not `email` on its own.

## Summary of API-level findings

| Result | Count |
|---|---|
| Pass | 34 |
| Fail | 6 (4 distinct root causes: BUG-01, BUG-02, BUG-03 ×2 occurrences, BUG-04 ×2 occurrences) |

Four confirmed defects, BUG-01 through BUG-04. Auth and authorization hold up everywhere except one spot: direct order retrieval (BUG-04). Input validation is mostly solid but has two real gaps, non-integer cart quantities (BUG-01) and out-of-range pagination (BUG-03). And registration doesn't check the email format at all (BUG-02).
