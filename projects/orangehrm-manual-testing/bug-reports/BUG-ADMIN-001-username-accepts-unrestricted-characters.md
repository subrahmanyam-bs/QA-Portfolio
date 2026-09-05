# BUG-ADMIN-001: Add User "Username" field accepts unrestricted special characters with no format validation

| Field | Value |
| :--- | :--- |
| **Bug ID** | BUG-ADMIN-001 |
| **Module** | Admin (User Management) |
| **Severity** | Low |
| **Priority** | Low |
| **Environment** | OrangeHRM OS 5.9, public demo instance, Chromium (Playwright-driven session), 2026-09-05 |
| **Reproducibility** | 100% (2/2 attempts) |
| **Status** | New |

---

## Preconditions
Logged in as Admin. On the Add User page (`/web/index.php/admin/saveSystemUser`).

## Steps to Reproduce
1. Select a valid User Role, Employee Name, and Status.
2. In the **Username** field, enter a string containing a space and single quotes, e.g. `' OR '1'='1`.
3. Fill Password and Confirm Password with a valid strong password.
4. Click **Save**.
5. Log out, then log back in using that exact string as the username.

## Test Data
* Username: `' OR '1'='1`
* Password: `Qa!Strong12345`

## Expected Result
The Username field should be restricted to a conventional, safe character set (letters, digits, and a small set of symbols such as `.` `_` `-`) and reject values containing spaces or quote characters — consistent with how usernames are normally constrained in HR/identity systems.

## Actual Result
The form accepted the value with no client-side validation error and saved successfully ("Success: Successfully Saved"), creating a fully functional account:
* The new user appears in the System Users grid with **Username: `' OR '1'='1`**, exactly as typed, linked to a real employee record, Status `Enabled`.
* Logging out and logging back in with username `' OR '1'='1` and the same password succeeded and reached the Dashboard as that user.

## Security Note
This is **not** a SQL-injection vulnerability. The backend clearly treats the string as an opaque literal value rather than interpolating it into a query: it was stored, retrieved, and matched on login character-for-character, with no error, no data corruption, and no unintended access. The real issue is a missing **input-format restriction**: a username containing quotes and spaces is unusual, and could still cause friction in systems that assume conventional usernames (CSV/report exports, LDAP or SSO integration, anything else that keys off this field) — even though it presents no exploitable risk in the application itself as tested here.

## Evidence
* `BUG-ADMIN-001-username-created.png` — System Users grid showing the created account with the literal payload as its username.
* `BUG-ADMIN-001-login-success.png` — Dashboard reached after logging in as that account.
* Reproduced via a scripted Playwright browser session against the live public demo on 2026-09-05 (real browser, real requests, real responses — not simulated). The test account was deleted immediately after verification to avoid leaving it in the shared demo environment.

## Related
See [`test-cases/admin/admin-test-cases.md`](../test-cases/admin/admin-test-cases.md) — TC-ADMIN-012.
