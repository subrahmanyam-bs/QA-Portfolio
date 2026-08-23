# Demo_Merchant_Platform

A public testing portfolio for the Demo Merchant Platform, demonstrating manual software testing practice: requirement analysis, test scenario identification, test case design, defect reporting, database validation, and test reporting.

---

## Disclaimer — please read first

- **Demo_Merchant_Platform is a fictional application.** It does not exist. I designed it myself, including its requirements, purely as a subject for test design.
- **This is a personal QA portfolio project**, not work performed for any employer.
- **The purpose of this repository is to demonstrate testing techniques** — how test cases are designed, how risks are identified, how defects are documented, and how results are reported.
- **No execution results are claimed.** Nothing in this repository has been executed against a running application. The test summary marks all test cases as Not Executed, and no execution results are claimed. The test summary demonstrates the structure and format of a test execution report; it contains no pass counts, fail counts or pass rates, because there has been no execution to measure. The defect reports are written examples showing how a defect would be analysed and documented, not defects found in a real system. If any content in this repository is ever based on actual execution, it will say so explicitly.
- **No employer confidential information is included.** No real requirements, defects, data, schemas, credentials, endpoints, error codes, business rules or internal documentation appear anywhere in this repository. All names, addresses and data are invented and use the reserved `example.com` domain.

---

## Application under test

| Field | Detail |
|-------|--------|
| **Name** | Demo_Merchant_Platform |
| **Type** | Fictional application, created for QA portfolio practice |
| **Description** | A web application where a merchant user signs in to view their account |
| **Purpose** | To demonstrate software testing techniques without using or exposing any confidential employer information |

### Requirements used as the basis for all test cases

Because no real product specification exists, I documented the assumed requirements myself. Every expected result in this repository traces back to one of these rules rather than to guesswork — that traceability is the point of stating them.

| ID | Rule |
|----|------|
| R1 | A user logs in with a registered email address and a password. |
| R2 | Passwords must be 8–20 characters and contain at least one uppercase letter, one digit and one special character. Complexity is enforced when a password is **set or reset**, not at login. |
| R3 | After 5 consecutive failed login attempts the account is locked for 30 minutes. |
| R4 | A successful login resets the consecutive-failure counter to zero. |
| R5 | An idle session expires after 15 minutes of inactivity. |
| R6 | A password reset link is valid for 15 minutes and can be used only once. |
| R7 | A user may hold active sessions on multiple devices at the same time. |
| R8 | The login screen returns the same generic error for an unregistered email and for a wrong password, so that valid accounts cannot be discovered. |
| R9 | Email addresses are treated case-insensitively; surrounding whitespace is trimmed. Passwords are case-sensitive. |
| R10 | A new password set during a reset must be different from the current password. Reuse of older passwords beyond the current one is not restricted. |
| R11 | When a user logs out, the server must invalidate the active session so that the authentication credential associated with it is rejected for any further authenticated request, regardless of its original expiry time. |

R11 is stated at the level of behaviour rather than mechanism. It deliberately does **not** specify whether the application uses cookie-based sessions, bearer tokens, or another mechanism, because that is an implementation decision. The requirement is that whatever credential the application uses stops working at logout. The test cases are written the same way, so they remain valid if the implementation changes.

Not specified, and recorded as gaps rather than assumed: the maximum accepted length of the email field, whether sessions are stateful or stateless, and what happens to other active sessions when a password is changed.

Deliberately not part of version 1, and recorded as known gaps rather than invented: SSO, two-factor authentication, CAPTCHA, IP-based rate limiting, mobile applications, biometric login.

---

## What version 1 contains

Version 1 covers the **login module only**, in depth. Other modules are on the roadmap below and are not present in the repository until they are actually written.

| Area | Location |
|------|----------|
| 23 detailed login test cases | `test-cases/login/login-test-cases.md` |
| Test scenarios with stated risk per scenario | `test-scenarios/login-scenarios.md` |
| 3 example defect reports | `bug-reports/login-bugs.md` |
| Backend validation queries | `sql-queries/validation-queries.sql` |
| Test summary report — format example | `test-summary/login-test-summary-example.md` |

### Testing areas covered within the login module

Positive functional flows · negative and error handling · boundary values · field and input validation · authentication behaviour · account lockout state machine · password masking · forgot and reset password · session management and idle timeout · multi-device concurrent sessions · logout and session invalidation · browser back-button behaviour after logout · direct URL access to protected pages · session token reuse · basic security checks including user enumeration and injection-style input · usability and keyboard accessibility.

---

## Testing techniques used

| Technique | Applied to |
|-----------|-----------|
| Equivalence Partitioning | Valid / invalid credential classes, email format classes |
| Boundary Value Analysis | Password length 7–8 and 20–21, lockout attempt 4–5–6, reset link and idle timeout at 15 minutes |
| Decision Table Testing | Email validity × password validity × account status |
| State Transition Testing | Active → locked → auto-unlocked; logged in → idle → expired |
| Error Guessing | Trailing whitespace, email case, browser back after logout, reset link reuse |
| Exploratory Testing | Usability and layout observations recorded as notes |

Each test case names the technique it came from, so the design intent is visible rather than implied.

---

## Tools

| Tool | Use |
|------|-----|
| Manual exploratory testing | Scenario discovery |
| Browser DevTools | Network calls, response headers, cached pages, DOM inspection |
| Postman | API-level verification of session and authentication behaviour |
| SQL client (PostgreSQL) | Backend data validation |
| Markdown / GitHub | Documentation and version control of test assets |
| Jira (format reference only) | Defect report structure |

---

## Folder structure

```
Demo_Merchant_Platform/
├── README.md
├── test-cases/
│   └── login/
│       └── login-test-cases.md            23 detailed login test cases
├── test-scenarios/
│   └── login-scenarios.md                 scenarios with stated risk
├── bug-reports/
│   └── login-bugs.md                      3 example defect reports
├── sql-queries/
│   └── validation-queries.sql             backend validation queries
└── test-summary/
    └── login-test-summary-example.md      test summary report format example
```

---

## Roadmap

Future modules are listed here rather than added as empty folders, so the repository always reflects what has actually been written.

| Version | Planned content |
|---------|-----------------|
| v1 (current) | Login module: test cases, scenarios, defect reports, SQL validation, test summary |
| v2 | User management: create and edit users, role and permission checks, privilege escalation, deactivation and reactivation, search and pagination, bulk actions |
| v3 | Payments: amount and currency validation, payment state transitions, duplicate prevention, timeout recovery, full and partial refunds, status notifications, reporting — designed from publicly documented payment concepts only |
| v4 | Merchant onboarding: multi-step form navigation, draft and resume, document upload, duplicate applications, approval workflow, rejection and resubmission, access control |
| v5 | Requirement traceability matrix and a risk-based test strategy document |

A separate repository will cover API and UI test automation.
