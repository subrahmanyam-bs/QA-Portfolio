# Test Cases - Products

**Module:** Products
**Interfaces under test:** `GET /store/products`, `GET /store/products/{id}`
**Environment:** Local Medusa v2.19.0, `http://localhost:9000`. Seed catalog: 4 products (Medusa Shorts, T-Shirt, Sweatpants, Sweatshirt), each with size variants, region "Europe" (EUR)
**Executed:** 2026-09-01 / 2026-09-02

| TC ID | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Priority | Test Type | Status |
|---|---|---|---|---|---|---|---|---|
| TC-PROD-001 | List all products with a valid publishable key | Valid publishable API key | — | 1. `GET /store/products` | `200 OK`; `count: 4`; all 4 seeded products present | High | Positive / Smoke | Pass |
| TC-PROD-002 | Retrieve a single product's full detail including variants and pricing | Valid `region_id` | `product_id = prod_...E76RN8WK0M2Y30ZQM1` (Medusa Shorts) | 1. `GET /store/products?limit=1&region_id={region}&fields=id,title,+variants.id,+variants.title,+variants.sku,*variants.calculated_price` | `200`; variants array includes SKU `SHORTS-M`/`SHORTS-S`/`SHORTS-XL` etc., each with a `calculated_price.calculated_amount` of `10` in `eur` | High | Positive / Functional | Pass |
| TC-PROD-003 | Retrieving a nonexistent product ID returns 404 | — | `prod_INVALID_ID_123` | 1. `GET /store/products/prod_INVALID_ID_123` | `404 {"type":"not_found","message":"Product with id: prod_INVALID_ID_123 was not found"}` | High | Negative | Pass |
| TC-PROD-004 | Product lookup by exact `handle` | — | `handle=shorts` | 1. `GET /store/products?handle=shorts&region_id={region}` | `200`; `count: 1`; returns "Medusa Shorts" | Medium | Positive / Functional | Pass |
| TC-PROD-005 | Free-text search (`q`) matches product title | — | `q=Shorts` | 1. `GET /store/products?q=Shorts&region_id={region}` | `200`; returns the matching product(s) | Medium | Positive / Functional | Pass |
| TC-PROD-006 | Requesting calculated pricing without a region context fails clearly | Valid publishable key, **no** `region_id` supplied | — | 1. `GET /store/products?limit=1&fields=...,*variants.calculated_price` (region_id intentionally omitted) | `400`, clear message stating the pricing context (region) is required | High | Negative / Validation | Pass |
| TC-PROD-007 | Passing region context as a header instead of a query parameter does not work | — | `x-region-id: {region}` header, no `region_id` query param | 1. `GET /store/products?...&*variants.calculated_price` with region sent only as a header | Documents actual contract: header is ignored; same `400` "region_id" error as TC-PROD-006 | Medium | Negative / API Contract | Pass — confirms `region_id` must be a query parameter (see `requirements/module-analysis.md` §8) |
| TC-PROD-008 | Pagination returns the requested page size | 4 products exist | `limit=2&offset=0` | 1. `GET /store/products?limit=2&offset=0&region_id={region}` | `200`; `count: 4` (total), `products.length: 2`, `limit: 2`, `offset: 0` | Medium | Positive / Boundary | Pass |
| TC-PROD-009 | `limit=0` returns zero items without error | — | `limit=0` | 1. `GET /store/products?limit=0&region_id={region}` | `200`; `products: []`, `count` still reflects the true total (4) | Medium | Boundary | Pass |
| TC-PROD-010 | Negative `limit` is rejected gracefully | — | `limit=-1` | 1. `GET /store/products?limit=-1&region_id={region}` | **Expected:** `400` with a validation message naming `limit`. | High | Negative / Boundary | **Fail** — returns `500 {"code":"unknown_error","type":"unknown_error","message":"An unknown error occurred."}`. See [BUG-03](../../bug-reports/BUG-03-negative-pagination-500.md) |
| TC-PROD-011 | Negative `offset` is rejected gracefully | — | `offset=-1` | 1. `GET /store/products?offset=-1&region_id={region}` | **Expected:** `400` with a validation message naming `offset`. | High | Negative / Boundary | **Fail** — same `500 unknown_error` as TC-PROD-010. See [BUG-03](../../bug-reports/BUG-03-negative-pagination-500.md) |
| TC-PROD-012 | Product images render from a valid, reachable URL | Product has a `thumbnail` field | — | 1. `GET /store/products?limit=1&fields=id,thumbnail` | `200`; `thumbnail` is a well-formed HTTPS URL | Low | Positive / Functional | Pass — thumbnail present and URL well-formed (image reachability itself was not fetched/verified) |
| TC-PROD-013 | Out-of-stock / zero-inventory variant is reflected accurately when adding to cart | A variant with insufficient inventory | Quantity exceeding seeded stock (`999999`) | 1. Attempt to add `999999` units of a variant to a cart | Rejected with a clear insufficient-inventory message (cross-referenced in `carts/cart-test-cases.md` TC-CART-008) | High | Positive / Functional | Pass (executed and documented under Carts, not duplicated here) |
| TC-PROD-014 | Admin dashboard product listing renders correctly in-browser | Admin dashboard reachable, logged in | — | 1. Log in to `http://localhost:9000/app`<br>2. Navigate to Products | Product grid renders with all 4 seeded products visible | Medium | UI | Blocked — no browser automation tool available in this environment |

## Summary

| Result | Count |
|---|---|
| Pass | 11 |
| Fail | 2 |
| Blocked | 1 |
| **Total** | **14** |

Retrieval, search, and handle lookup all check out against the seeded data. Both failures are really the same bug wearing two hats — `limit` and `offset` both crash instead of validating when negative — so they're tracked under one report, BUG-03.
