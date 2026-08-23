# OrangeHRM Login Module Test Summary Report

This summary report aggregates the execution metrics, defects, observations, and conclusions derived from testing the OrangeHRM Login Module.

---

## 1. Executive Summary
Testing was conducted on the Login Module of the OrangeHRM public demo application to verify that the authentication layout, input validations, credentials matching, session management, navigation, and usability conform to manual testing guidelines. 

The execution resulted in a **100% pass rate** for all executed test cases. The application successfully validates mandatory fields, rejects invalid entries, handles leading and trailing whitespaces literally, and allows seamless session termination on logout. No defects were logged during this testing cycle.

---

## 2. Scope
- **Target Module**: Login Module only.
- **In-Scope**: Visual presence checks, field masking, required validations, positive/negative credential entries, case sensitivity, tab ordering, Enter key form submission, and viewport scalability.
- **Out-of-Scope**: Database validation, automated regression test runs, performance/load testing, security penetration/lockout exploitation, and post-login pages (PIM, Leave, Admin modules) beyond dashboard redirection.

---

## 3. Environment
Testing was executed on Chromium (v133.0) on Windows 11. The application was hosted on the public demo instance: `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`.

---

## 4. Execution Statistics

| Metric | Count | Percentage |
| :--- | :---: | :---: |
| **Total Test Cases** | 22 | 100.0% |
| **Passed** | 20 | 90.9% |
| **Failed** | 0 | 0.0% |
| **Blocked** | 0 | 0.0% |
| **Not Executed** | 2 | 9.1% |
| **Overall Pass Rate** | — | **100.0%** (of executed cases) |

---

## 5. Passed Tests
Twenty test cases were executed and passed successfully. Key verifications include:
- Visual presence of all forms, images, and labels (TC-001).
- Correct password masking and lack of visibility toggles (TC-002).
- Required field indicators under empty or partial credential submissions (TC-003).
- Graceful validation errors under whitespace entries and special characters (TC-004, TC-005).
- Redirection to `/web/index.php/dashboard/index` on valid authentication (TC-008).
- Outputting `"Invalid credentials"` banners on incorrect entries (TC-009).
- Successful navigation blocks on deep-linking without cookies (TC-014).
- Syncing session status across multi-tab browsing (TC-016).
- Sequential Tab focus shifting and Enter key click bindings (TC-019, TC-020).

---

## 6. Failed Tests
* **None**: Zero test cases failed during this execution cycle.

---

## 7. Blocked Tests
* **None**: No test cases were blocked by scripting, tooling, or database limitations.

---

## 8. Not Executed Tests
Two test cases were left in the `Not Executed` state:
- **TC-LOGIN-017** (Inactivity Session Expiration): Waiting 15+ minutes was not performed as it is impractical during active manual testing sessions.
- **TC-LOGIN-022** (Cross-Browser Compatibility): Testing on Edge, Firefox, and Safari was not performed because these browsers are not locally configured in the testing context.

---

## 9. Defect Summary
* **Total Defects Logged**: `0`
* **Defect breakdown**: No reproducible defects or deviations from expected functional behaviors were observed.

---

## 10. Risks & Limitations
- **Shared Public Environment**: The target OrangeHRM instance is public. If another user modifications are done (e.g. changing Admin password) or if the server resets, test execution would be impacted.
- **Single Browser Limitation**: Testing was restricted to Chromium, leaving rendering and compatibility states on Edge, Safari, and Firefox unverified.
- **No Lockout Observed**: No account lockout or login restriction was observed after five consecutive failed login attempts on this public demo environment. This presents a minor risk if security hardening tests are required.

---

## 11. Key Observations
* **Case-Insensitive Username Observation**: The application successfully accepted the lowercase username 'admin' when paired with the valid demo password during testing, indicating that username matching on the backend is case-insensitive.
* **Literal Whitespace**: Leading and trailing whitespaces in the Username field are not trimmed and are treated literally (failed login), which represents a strict validation design choice.
* **Clean Back Navigation**: Clicking the Back button after explicit logout correctly displays the Login page at the login URL and prevents re-entering the dashboard.

---

## 12. Final Testing Conclusion
Based on the executed scope of 20 test cases, the OrangeHRM Login Module behaves in accordance with the documented test expectations. Authentication, inline field validations, and basic redirection structures operate cleanly. However, compatibility across non-Chromium browser engines and long-term inactivity session behavior remain unverified.
