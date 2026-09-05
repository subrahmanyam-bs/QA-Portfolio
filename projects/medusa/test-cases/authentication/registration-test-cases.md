# Test Cases - Customer Registration

**Module:** Authentication / Customer
**Interfaces under test:** `POST /auth/customer/emailpass/register` (creates the auth identity + JWT), `POST /store/customers` (creates the linked customer profile)
**Environment:** Local Medusa v2.19.0, `http://localhost:9000`
**Executed:** 2026-09-01

Medusa's customer registration is a two-step flow: (1) register an auth identity and receive a JWT, (2) use that JWT to create the actual `customer` profile via the Store API. Both steps were exercised.

| TC ID | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Priority | Test Type | Status |
|---|---|---|---|---|---|---|---|---|
| TC-REG-001 | Full registration succeeds with valid, new data | Email not previously registered | `qa.customer1@example.com` / valid password | 1. `POST /auth/customer/emailpass/register` → get JWT<br>2. `POST /store/customers` with that JWT and profile fields | Step 1: `200`, JWT returned. Step 2: `200`, `customer` object returned with matching email, `has_account: true` | High | Positive / Functional | Pass |
| TC-REG-002 | Duplicate registration with an already-used email is rejected | Email from TC-REG-001 already registered | Same email, any password | 1. `POST /auth/customer/emailpass/register` again with the same email | `401 {"type":"unauthorized","message":"Identity with email already exists"}`; no second identity created | High | Negative / Boundary | Pass |
| TC-REG-003 | Registration is rejected when the password field is missing | — | `{"email": "missingpw@example.com"}` | 1. `POST /auth/customer/emailpass/register` with no `password` key | Rejected (4xx) | High | Negative / Boundary | Pass — same status-code observation as TC-AUTH-004, see note |
| TC-REG-004 | Registration accepts a syntactically invalid email address | — | `email: "not-an-email"`, valid password | 1. `POST /auth/customer/emailpass/register` with a non-email string as `email` | **Expected:** rejected (4xx) with a validation error naming the `email` field. | High | Negative / Boundary | **Fail** — request succeeds with `200` and a valid JWT is issued. See [BUG-02](../../bug-reports/BUG-02-invalid-email-accepted.md) |
| TC-REG-005 | Registered customer can immediately log in with the same credentials | TC-REG-001 completed | Same email/password used to register | 1. `POST /auth/customer/emailpass` with the credentials just registered | `200`, JWT returned | High | Positive / Functional | Pass |
| TC-REG-006 | A guest checkout email and a registered-customer email can coexist as separate records | TC-REG-001 completed for `qa.customer1@example.com`; a separate guest checkout completed with a different email | Guest email `qa.tester+cart1@example.com` (has_account=false) vs. registered email `qa.customer1@example.com` (has_account=true) | 1. Query the `customer` table for both emails (see `database-testing/database-test-cases.md`, DB-CUST-01) | Two distinct `customer` rows exist, differentiated by `has_account` | Medium | Edge Case / Data Consistency | Pass |
| TC-REG-007 | Customer profile creation requires a valid customer bearer token | Valid publishable key, no bearer token | `{"email":"noauth@example.com","first_name":"No","last_name":"Auth"}` | 1. `POST /store/customers` with `x-publishable-api-key` but no `Authorization` header | `401 {"message":"Unauthorized"}`; no record created | High | Negative / Security | Pass |
| TC-REG-008 | Registration is rejected for an empty-string email | — | `email: ""`, valid password | 1. `POST /auth/customer/emailpass/register` with `email` set to an empty string | Rejected (4xx) | Medium | Boundary | Not Executed |
| TC-REG-009 | Registration handles a very long email/local-part gracefully | — | Email with a 200+ character local part | 1. `POST /auth/customer/emailpass/register` with an oversized email string | Either accepted consistently or rejected with a clear validation error — no server error (5xx) | Low | Boundary | Not Executed |
| TC-REG-010 | Password with only whitespace is not treated as a valid password | — | `password: "   "` | 1. `POST /auth/customer/emailpass/register` with a whitespace-only password | Rejected, or if accepted, must actually be usable for login without being trimmed inconsistently | Low | Boundary | Not Executed |

## Notes

**TC-REG-004** is a real bug, filed as [BUG-02](../../bug-reports/BUG-02-invalid-email-accepted.md). Worth spelling out why it's not just a judgment call: Medusa validates other fields strictly elsewhere (cart quantity, for one), so having zero email-format checking on the field that IS the login identity doesn't fit the rest of the API's posture.

**TC-REG-003** hits the same status-code quirk as the admin login cases (`401` with `"Password should be a string"` instead of `400`). Already covered once in `login-test-cases.md` and rolled up in `api-testing/api-test-cases.md`, so not repeating it as its own bug here.

## Summary

| Result | Count |
|---|---|
| Pass | 6 |
| Fail | 1 |
| Not Executed | 3 |
| **Total** | **10** |

One real defect (BUG-02). Duplicate-email rejection, token enforcement on profile creation, and the guest/registered coexistence all checked out fine.
