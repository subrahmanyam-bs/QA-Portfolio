# BUG-03: Negative `limit`/`offset` on product listing crashes with a 500 instead of a validation error

| Field | Value |
|---|---|
| **Bug ID** | BUG-03 |
| **Title** | `GET /store/products` returns `500 unknown_error` for a negative `limit` or `offset`, instead of a `400` |
| **Module** | Products / Store API |
| **Environment** | Medusa v2.19.0, local instance, `http://localhost:9000`, PostgreSQL 17.11 |
| **Preconditions** | Valid publishable API key |
| **Severity** | Medium |
| **Priority** | High |
| **Reproducibility** | 100%. Twice for `limit`, once for `offset`, all separate requests |
| **Status** | New |

## Steps to Reproduce
1. `GET /store/products?limit=-1&region_id={valid_region_id}` with a valid `x-publishable-api-key`.
2. Note the status code and body.
3. Same again with `offset=-1` instead of `limit`.

## Test Data
- `limit=-1`
- `offset=-1`
- For contrast: `limit=0` works fine — `200`, empty `products` array, correct `count`.

## Expected Result
Both should come back `400`, naming whichever parameter is out of range. That's the same class of response the API already gives for other bad input on this same endpoint (invalid `region_id`, for instance).

## Actual Result
Both blow up server-side instead:
```
GET /store/products?limit=-1&region_id=reg_01M1ETAF0Q08A76RN6Y6X542QD
→ 500
{"code":"unknown_error","type":"unknown_error","message":"An unknown error occurred."}

GET /store/products?offset=-1&region_id=reg_01M1ETAF0Q08A76RN6Y6X542QD
→ 500
{"code":"unknown_error","type":"unknown_error","message":"An unknown error occurred."}
```
This isn't a generic "we mapped your bad input to a 500" situation either — the server log shows a real unhandled exception, and the stack trace bottoms out in the query builder's pagination code (`@mikro-orm/knex` `QueryBuilder.wrapPaginateSubQuery` → `QueryBuilder.as` → `PostgreSqlDriver.find`). Reads like the negative value is going straight into the SQL `LIMIT`/`OFFSET` clause with nothing checking it first.

## Why it matters
A `500` with a message that says nothing tells the caller nothing useful, which is a step backward from how consistent the rest of this API's error handling is. And a query param that can crash the server with zero auth and zero complexity behind it is exactly the kind of thing that should get caught before it ships.

## Evidence
Request/response and a trimmed stack trace above; full write-up in `test-cases/products/product-test-cases.md` (TC-PROD-010, TC-PROD-011).
