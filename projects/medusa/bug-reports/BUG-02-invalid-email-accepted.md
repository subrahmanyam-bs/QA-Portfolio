# BUG-02: Customer registration accepts a syntactically invalid email address

| Field | Value |
|---|---|
| **Bug ID** | BUG-02 |
| **Title** | `POST /auth/customer/emailpass/register` performs no email-format validation |
| **Module** | Authentication / Customer Registration |
| **Environment** | Medusa v2.19.0, local instance, `http://localhost:9000` |
| **Preconditions** | None (anonymous endpoint) |
| **Severity** | Medium |
| **Priority** | Medium |
| **Reproducibility** | 100%, tried twice with different garbage strings |
| **Status** | New |

## Steps to Reproduce
1. `POST /auth/customer/emailpass/register`:
   ```json
   {"email": "not-an-email", "password": "Test1234"}
   ```
2. See what comes back.

## Test Data
- `email: "not-an-email"` — no `@`, no domain, doesn't pass basic email syntax by any standard
- `password: "Test1234"`

## Expected Result
Rejected, `400`/`422`-class error naming `email`. The same route already type-checks `password` (see the "missing password" cases in `test-cases/authentication/registration-test-cases.md`), so the email field should get at least the same treatment.

## Actual Result
It just works. `200 OK`, a fully usable JWT comes back:
```
POST /auth/customer/emailpass/register
{"email":"not-an-email","password":"Test1234"}

→ 200
{"token":"eyJhbGciOiJIUzI1NiIs...<valid JWT>...`}
```
Nothing downstream catches it either — this becomes a real, working account.

## Why it's a problem, not just a nitpick
The `email` field here doubles as the account's login identity, so:
- The account can never receive anything at that "address" — order confirmations, marketing, none of it, since there's no real mailbox behind it.
- Password reset by email is dead on arrival for this account — there's nowhere to send the link.
- It's a genuine inconsistency in the API, not just a missing nice-to-have: `password` on this exact route is type-checked, `email` isn't checked at all.

## Evidence
Request/response above, and `test-cases/authentication/registration-test-cases.md` (TC-REG-004).
