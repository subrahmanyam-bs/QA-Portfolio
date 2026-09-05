# Test Execution Summary

**Execution dates:** 2026-09-01 and 2026-09-02
**Environment:** Local Medusa v2.19.0 instance (see `requirements/module-analysis.md`)
**Executed by:** API-level black-box testing directly against the live local backend, using `curl`, cross-checked against the database with `psql` where relevant.

## Evidence approach used in this project

The evidence for this project is the literal HTTP request and response, captured for each test case in the corresponding file under `test-cases/`, `api-testing/api-test-cases.md`, and `bug-reports/`. For API-first testing that request/response pair basically is the evidence: anyone with the same environment can reproduce it exactly, which honestly holds up better than a screenshot would for this kind of work.

## Why `test-execution/screenshots/` is empty

No browser automation tool was available in this environment or session, so no genuine screenshots of the Admin dashboard (`http://localhost:9000/app`) or the public storefront (`https://next.medusajs.com`) could be taken. Rather than fake it or claim UI testing that never happened, every test case needing visual/interactive browser verification is marked **Blocked** in its own file, with the reason spelled out.

If a browser tool shows up in a future session, the Blocked cases below are the ones to run next, and their screenshots would go in this folder.

## Smoke test set (executed, prioritized first)

| Check | Result |
|---|---|
| `GET /health` | `200 OK`, Pass |
| Admin login (`POST /auth/user/emailpass`) | `200`, JWT issued, Pass |
| Customer login (`POST /auth/customer/emailpass`) | `200`, JWT issued, Pass |
| Product listing (`GET /store/products`) | `200`, 4 products returned, Pass |
| Cart creation (`POST /store/carts`) | `200`, cart created, Pass |
| Full checkout (cart to order) | `200`, order `display_id: 1` created, Pass |

All six smoke checks passed. `GET /health` got re-run as a sanity check every time execution resumed across the two sessions, just to make sure nothing had drifted.

## Executed test case totals (by file)

| File | Pass | Fail | Blocked | Not Executed | Total |
|---|---|---|---|---|---|
| `test-cases/authentication/login-test-cases.md` | 15 | 0 | 1 | 1 | 17 |
| `test-cases/authentication/registration-test-cases.md` | 6 | 1 | 0 | 3 | 10 |
| `test-cases/products/product-test-cases.md` | 11 | 2 | 1 | 0 | 14 |
| `test-cases/carts/cart-test-cases.md` | 15 | 1 | 0 | 0 | 16 |
| `test-cases/customers/customer-test-cases.md` | 7 | 0 | 1 | 0 | 8 |
| `test-cases/regions/region-test-cases.md` | 6 | 0 | 1 | 1 | 8 |
| `test-cases/orders/order-test-cases.md` | 8 | 1 | 1 | 0 | 10 |
| **Total** | **68** | **5** | **5** | **5** | **83** |

(`api-testing/api-test-cases.md` re-documents the same underlying requests from an API-contract angle rather than as separately-counted test cases, to avoid double-counting the same execution in the totals above.)

## Blocked test cases (UI, no browser tool available)
- TC-AUTH-016: password field masking
- TC-PROD-014: Admin product grid rendering
- TC-CUST-008: address book UI add/edit
- TC-REGION-008: region/currency selector UI
- TC-ORDER-010: order confirmation page rendering

## Not Executed test cases (with reason)
- TC-AUTH-017: token expiry. Waiting out a ~24h token lifetime wasn't practical here.
- TC-REG-008/009/010: empty-string email, oversized email, whitespace-only password. Lower-priority boundary variants, didn't get to them this round.
- TC-REGION-007: cross-region country code acceptance. Also lower priority, time-boxed out.
