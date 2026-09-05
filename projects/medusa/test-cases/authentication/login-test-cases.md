# Test Cases - Login & Authorization

**Module:** Authentication
**Interfaces under test:** `POST /auth/user/emailpass` (admin), `POST /auth/customer/emailpass` (customer), protected route enforcement on `/admin/*` and `/store/customers*`
**Environment:** Local Medusa v2.19.0, `http://localhost:9000` (see `requirements/module-analysis.md`)
**Executed:** 2026-09-01

| TC ID | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Priority | Test Type | Status |
|---|---|---|---|---|---|---|---|---|
| TC-AUTH-001 | Admin logs in with valid credentials | Admin account `qa.admin@medusa-qa.local` exists | Valid email + valid password | 1. `POST /auth/user/emailpass` with valid `email`/`password` | `200 OK`; response body contains a non-empty JWT `token` | High | Positive / Functional | Pass |
| TC-AUTH-002 | Admin login rejected with wrong password | Admin account exists | Valid email, incorrect password | 1. `POST /auth/user/emailpass` with valid email, wrong password | `401`; generic error, no indication of which field was wrong | High | Negative | Pass |
| TC-AUTH-003 | Admin login rejected for nonexistent account | — | Email not registered as any user | 1. `POST /auth/user/emailpass` with an unregistered email + any password | `401` with a generic message (no "user not found" style disclosure) | High | Negative / Security | Pass |
| TC-AUTH-004 | Admin login rejected when password field is missing | — | `{"email": "..."}`, no `password` key | 1. `POST /auth/user/emailpass` with body containing only `email` | Request rejected (4xx) with a message indicating the password is required/invalid | Medium | Negative / Boundary | Pass — see note below |
| TC-AUTH-005 | Admin login rejected with an empty request body | — | `{}` | 1. `POST /auth/user/emailpass` with `{}` | Request rejected (4xx) | Medium | Negative / Boundary | Pass — see note below |
| TC-AUTH-006 | Admin API route rejects requests with no Authorization header | Admin account exists, but no token sent | — | 1. `GET /admin/products` with no `Authorization` header | `401 {"message":"Unauthorized"}` | High | Negative / Security | Pass |
| TC-AUTH-007 | Admin API route rejects a malformed/garbage bearer token | — | `Authorization: Bearer not.a.valid.jwt` | 1. `GET /admin/products` with an invalid token string | `401 {"message":"Unauthorized"}` | High | Negative / Security | Pass |
| TC-AUTH-008 | Customer logs in with valid credentials | Customer `qa.customer1@example.com` registered (see registration test cases) | Valid email + valid password | 1. `POST /auth/customer/emailpass` with valid credentials | `200 OK`; response contains a non-empty JWT `token` | High | Positive / Functional | Pass |
| TC-AUTH-009 | Customer login rejected with wrong password | Customer account exists | Valid email, wrong password | 1. `POST /auth/customer/emailpass` with valid email, wrong password | `401 {"type":"unauthorized","message":"Invalid email or password"}` | High | Negative | Pass |
| TC-AUTH-010 | Customer login rejected for nonexistent account, with the same generic message as a wrong password | — | Unregistered email | 1. `POST /auth/customer/emailpass` with an unregistered email | `401`, identical generic message to TC-AUTH-009 (no account-enumeration signal) | High | Negative / Security | Pass |
| TC-AUTH-011 | Customer-scoped endpoint rejects requests with no bearer token | Valid publishable API key available | — | 1. `GET /store/customers/me` with `x-publishable-api-key` but no `Authorization` header | `401 {"message":"Unauthorized"}` | High | Negative / Security | Pass |
| TC-AUTH-012 | Customer-scoped endpoint rejects a POST with no bearer token | Valid publishable API key available | `{"email":"noauth@example.com", "first_name":"No", "last_name":"Auth"}` | 1. `POST /store/customers` with `x-publishable-api-key` but no `Authorization` header | `401 {"message":"Unauthorized"}`; no customer record created | High | Negative / Security | Pass |
| TC-AUTH-013 | Authenticated customer can retrieve their own profile | Customer logged in, holds a valid JWT | Valid customer JWT | 1. `GET /store/customers/me` with `Authorization: Bearer <customer JWT>` and valid publishable key | `200 OK`; response `customer.email` matches the logged-in account | High | Positive / Functional | Pass |
| TC-AUTH-014 | Store API rejects requests with no publishable API key | — | — | 1. `GET /store/products` with no `x-publishable-api-key` header | `400`, clear message naming the missing header | High | Negative | Pass |
| TC-AUTH-015 | Store API rejects an invalid publishable API key | — | Well-formed but non-existent key (`pk_wrongkey...`) | 1. `GET /store/products` with an invalid `x-publishable-api-key` | `400 {"type":"not_allowed","message":"A valid publishable key is required to proceed with the request"}` | High | Negative | Pass |
| TC-AUTH-016 | Password field is masked in the Admin login UI | Admin dashboard reachable | — | 1. Open `http://localhost:9000/app` login form<br>2. Inspect the password input | Password characters are visually masked | Medium | UI | Blocked — no browser automation tool available in this environment (see `requirements/module-analysis.md` §9) |
| TC-AUTH-017 | Session/token expiry is enforced | A JWT older than its `exp` claim | Expired token | 1. Wait for token expiry (or use a pre-expired token)<br>2. Call a protected endpoint | Request rejected as unauthorized | Medium | Negative / Session | Not Executed — token lifetime (~24h) makes this impractical to wait out within this project's timeframe; not fabricated |

## Notes

**On TC-AUTH-004 / TC-AUTH-005.** Both get rejected, which is what actually matters here from a security standpoint. What's a little off is the status code: `401 Unauthorized` with `"Password should be a string"`. That's a shape-of-the-request problem, not an auth failure, so `400` would fit better. Didn't log it separately since the request is still correctly refused either way, but flagging it here since it comes up again in `api-testing/api-test-cases.md`.

## Summary

| Result | Count |
|---|---|
| Pass | 15 |
| Blocked | 1 |
| Not Executed | 1 |
| **Total** | **17** |

Login held up well. No account enumeration on either endpoint, protected routes reject missing/bad tokens correctly, and the publishable-key gate does exactly what it's supposed to. No defects out of this module.
