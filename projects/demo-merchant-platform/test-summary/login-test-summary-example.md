# Test Summary Report (Format Example) — Login Module

**Application under test:** Demo_Merchant_Platform (fictional — see repository README)
**Module:** Authentication / Login

> ## Execution Status: Not Executed
>
> **This document demonstrates the structure and format of a test execution report. No actual test execution results are being claimed.**
>
> Demo_Merchant_Platform is a fictional application. It does not exist, no build of it has ever been run, and none of the 23 test cases in this repository have been executed against anything.
>
> Every test case in this repository therefore carries the status **Not Executed**. No pass counts, fail counts, pass rates or other execution metrics appear in this document, because there has been no execution to measure. Sections that would normally contain results instead describe **what would be recorded there and how it would be reasoned about**.
>
> The value of this document is in showing that I know what a test summary report must contain, how results are broken down, how defects are linked back to test cases, how exit criteria are defined before a cycle starts, and how a release recommendation is justified rather than asserted.

---

## 1. Objective

Verify that the login module of Demo_Merchant_Platform meets documented requirements R1–R11, with particular attention to authentication correctness, the account lockout mechanism, password reset security and session management.

## 2. Scope

**In scope**

- Login with valid and invalid credentials
- Field-level input validation
- Account lockout and automatic unlock
- Forgot password and password reset
- Session creation, concurrency, idle timeout, logout and post-logout access
- Backend verification of user, attempt and session data
- Basic security checks: user enumeration, injection-style input, password masking, session token reuse

**Out of scope**

- Two-factor authentication, SSO, CAPTCHA and IP-based rate limiting — not present in this application
- Mobile browsers and responsive layouts
- Cross-browser matrix beyond two desktop browsers
- Performance and load testing
- Penetration testing — the security checks here are functional-level only and are not a substitute for a security assessment
- Response-time based user enumeration — not reliably measurable manually; see TC_LOGIN_007

## 3. Test environment

The rows below show what would be recorded. No environment was used and no values are claimed.

| Item | What would be recorded |
|------|-----------------------|
| Environment | QA environment name |
| Build | Build number under test |
| Operating system | OS and version of the test machine |
| Browsers | Browser names and versions |
| Screen resolutions | Resolutions covered |
| API testing | API client and version |
| Database | Database engine and access level (read-only) |
| Test data | Dedicated QA accounts on the reserved `example.com` domain |

---

## 4. Test design coverage

The figures in this section count **test cases written**, which is a fact about this repository. They are not execution results.

| Metric | Count |
|--------|-------|
| Test cases designed | 23 |
| Test cases executed | 0 |
| Execution status | Not Executed |

### Test cases designed, by type

Each test case is counted once, under the primary test type shown in the index of `test-cases/login/login-test-cases.md`.

| Test type | Designed | Execution status | Test case IDs |
|-----------|----------|------------------|---------------|
| Functional | 3 | Not Executed | 001, 002, 012 |
| Negative | 1 | Not Executed | 006 |
| Validation | 3 | Not Executed | 004, 005, 017 |
| Boundary | 3 | Not Executed | 010, 013, 016 |
| Security | 7 | Not Executed | 003, 007, 009, 011, 014, 015, 022 |
| Session | 5 | Not Executed | 018, 019, 020, 021, 023 |
| Usability | 1 | Not Executed | 008 |
| **Total** | **23** | **Not Executed** | |

### How this section would be completed after execution

Each test case would be given a result of Passed, Failed, Blocked or Not Run. The table above would gain Passed and Failed columns, a pass rate would be calculated, and every failed case would be linked to the defect raised for it. Blocked cases would be listed separately with the reason, since a blocked case is a coverage gap and not a pass.

---

## 5. Defect reports included in this repository

The repository contains **3 example defect reports** in `bug-reports/login-bugs.md`. These are written examples that demonstrate defect analysis and documentation. They were not found by testing a real system, and no defect counts, densities or trends are claimed.

| Defect ID | Title | Severity assigned in the example | Related test cases |
|-----------|-------|----------------------------------|--------------------|
| BUG_LOGIN_001 | Failed login attempt counter is not reset after a successful login | Major | TC_LOGIN_012 |
| BUG_LOGIN_002 | Email validation error is not cleared after the field is corrected | Minor | TC_LOGIN_004, TC_LOGIN_008 |
| BUG_LOGIN_003 | Authentication credential remains accepted after logout | Critical | TC_LOGIN_020, TC_LOGIN_022 |

The mapping above is worth noting for one reason: BUG_LOGIN_003 relates to two test cases. Splitting logout verification into four separate cases (TC_LOGIN_019 to TC_LOGIN_022) is what makes it possible to show that a single root cause has two distinct user-facing symptoms while two other aspects of logout are unaffected. A single bundled "logout works" test case could not express that.

### How this section would be completed after execution

It would report defects raised in the cycle by severity and by status, defect density against test cases executed, how many defects were found by user-interface testing versus backend and API verification, and the ageing of anything still open at the end of the cycle.

---

## 6. Exit criteria

Exit criteria are defined **before** a cycle begins, which is why they can be stated here even though nothing has been executed. The assessment column is left open deliberately.

| Criterion | Target | Assessment |
|-----------|--------|-----------|
| Test case execution | 100% of designed cases executed | Not assessed — not executed |
| Pass rate | ≥ 95% | Not assessed — not executed |
| Critical defects open | 0 | Not assessed — not executed |
| Major defects open | 0 | Not assessed — not executed |
| Requirements covered | R1–R11 | Design coverage complete; execution coverage not assessed |
| Blocked test cases | 0 | Not assessed — not executed |

---

## 7. Risks identified during test design

These risks come from analysing the requirements and designing the tests. They do not depend on execution, so they are stated as findings rather than as placeholders.

| Risk | Impact | Mitigation |
|------|--------|-----------|
| No IP-based rate limiting in the requirements | Per-account lockout does not stop an attack spread across many accounts | Raise as a requirement gap before the next release |
| Requirements do not state whether a blocked client-side submission counts toward lockout | Ambiguity means the same behaviour could be judged a pass or a fail | Confirm with the product owner; recorded as an assumption on TC_LOGIN_005 |
| Requirements do not state what happens to other sessions when a password is changed | A likely security gap that cannot be tested until specified | Raise as a requirement gap |
| Timeout-dependent cases need configuration or database access to run | Cases TC_LOGIN_013, 016 and 023 are impractical to execute at production timings | Agree shortened values for the QA environment before the cycle starts |
| Response-time enumeration is not manually measurable | A real enumeration channel would go unverified | Cover by automation; recorded as a gap in the scenarios document |
| Manual execution only | Regression cost grows with every release | Automate the login regression suite |

---

## 8. Recommendation

No release recommendation is made, because nothing has been executed. Making one would be an invented result.

What this section would contain after a real cycle, and the reasoning that would drive it:

- A clear go or no-go statement for the module, not a summary of what happened.
- The decision rule applied: any open critical defect in authentication or session handling is a blocker regardless of the pass rate, because those defects affect every user and cannot be worked around. A high pass rate does not offset a critical defect.
- Which defects must be fixed before release, which can be deferred, and the justification for each.
- The retest and regression scope once fixes are available — for this module, the failed cases plus regression across the lockout and session cases, since those areas share code paths and a fix in one is likely to affect the others.
