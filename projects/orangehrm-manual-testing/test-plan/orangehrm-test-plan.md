# OrangeHRM Login Module Test Plan

**Document Version**: 1.0  
**Status**: `Completed`  
**Target Module**: Login Module  

---

## 1. Scope
This test plan defines the strategy, resources, environment, and workflow for the manual verification of the OrangeHRM Login Module. It is limited to the user authentication interface and related controls.

### In Scope
- Verification of credential inputs (Username and Password fields).
- Behavior of the Login action when triggered via button click or Enter key.
- Input validation checks (empty fields, invalid formatting, password character masking).
- Handling of valid and invalid username/password combinations.
- Verification of basic user-facing session transitions (logging out, redirection to dashboard).
- Verification of the password recovery request trigger ("Forgot your password?" flow), planned only if the password recovery entry point is actually available in the application UI.
- UI and layout visibility across target web browsers.

### Out of Scope
- Backend database schema verification (direct validation of credentials tables).
- Penetration testing or brute-force lockout threshold exploitation at the API/server level.
- Performance, load, or stress testing of the authentication endpoints.
- Verification of post-login dashboard modules (PIM, Leave, Admin) beyond the initial redirect.
- Automated regression suites (all test cases are designed for manual black-box verification and executed manually).

---

## 2. Objectives
The objective of this testing cycle is to evaluate the observable functional, validation, usability, and navigation behavior of the OrangeHRM Login module against defined test conditions:
- Confirm that valid users can successfully authenticate and access authorized pages.
- Confirm that invalid or blank credential attempts are rejected with appropriate, non-revealing error messages.
- Verify that credentials are visually protected (masked) on screen.
- Verify that logout actions correctly terminate the user session and redirect the user back to the login interface.
- Ensure that the login layout renders correctly across specified browser environments.

---

## 3. Test Environment
The testing environment details will be confirmed and populated once hands-on exploration begins.

| Parameter | Target Specification (Placeholder) | Actual Value (Log during execution) |
| :--- | :--- | :--- |
| **Application URL** | `To Be Verified` | `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login` |
| **Environment** | `To Be Verified (e.g., Public Demo / Staging)` | `Public Demo` |
| **Browser** | `To Be Verified (e.g., Chrome / Firefox)` | `Google Chrome` |
| **Browser Version** | `To Be Verified` | `v133.0` |
| **Operating System**| `To Be Verified (e.g., Windows / macOS / Linux)` | `Windows 11` |
| **Device** | `To Be Verified (e.g., Desktop / Laptop)` | `Desktop Laptop` |
| **Test Account** | `To Be Verified (e.g., Admin / Standard Employee)` | `Admin (Credentials: Username: Admin / Password: Valid Demo Admin Password)` |
| **Test Data** | `To Be Verified` | `Valid Demo Admin credentials, invalid strings, whitespaces` |

---

## 4. Entry Criteria
The following conditions must be satisfied before manual test execution for the Login module can begin:
1. The target OrangeHRM demo instance is accessible online and displaying a stable login page.
2. Required test credentials are available and their source is documented.
3. The Login module analysis has been completed and documented in the requirements framework.
4. The manual test cases for the Login module have been written, reviewed, and finalized.
5. The execution environment (browser and OS) has been prepared and documented.

*Status Check:* **`Completed`** — All entry criteria successfully satisfied; login exploration and manual test design phases completed.

---

## 5. Exit Criteria
Login module testing will be considered complete when the following conditions are met:
1. All planned Login test cases have been manually executed.
2. Actual results, pass/fail status, and observation details have been recorded for each test case.
3. All observed failures or deviations from expected behavior have been investigated.
4. Reproducible defects have been logged with step-by-step instructions.
5. Required retesting/regression testing of resolved issues has been performed, where applicable.
6. Relevant test execution evidence (such as screenshots for failed states) has been collected.
7. The Login test summary report has been compiled and finalized.

---

## 6. Risks
The following testing risks have been identified:
- **Shared/Public Demo Environment**: The shared/public demo environment may be modified or reset independently of this testing activity, which may affect test reproducibility.
- **Environment Availability**: Outages, resets, or network latency of the public OrangeHRM demo site may delay or interrupt execution.
- **Application Changes**: Unannounced updates or modifications to the demo instance by the vendor may invalidate designed test cases.
- **Browser Compatibility**: Layout alignment or script execution issues may vary between different browser engines.
- **Session/Environment Instability**: Unpredictable cookie/session drops on the shared demo server could affect verification of logout or session timeout behaviors.

---

## 7. Assumptions
- Test credentials (usernames and passwords) are available and published by the demo application provider.
- No direct database access is available; verification is restricted purely to externally observable front-end and application behaviors.
- The environment configuration may change without prior notice.

---

## 8. Deliverables
The following deliverables have been successfully finalized for this module testing cycle:
* **Login Test Plan** (This document - Completed)
* **Login Test Cases** (Created in [login-test-cases.md](../test-cases/login/login-test-cases.md) - Completed)
* **Test Execution Results** (Recorded in [login-test-execution.md](../test-execution/login-test-execution.md) - Completed)
* **Execution Evidence** (Screenshots stored in [screenshots/](../test-execution/screenshots/) - Completed)
* **Login Test Summary** (Created in [login-test-summary.md](../test-summary/login-test-summary.md) - Completed)

---

## 9. Test Execution Approach
The execution workflow will proceed according to the following sequential phases:
1. **Explore the Login module**: Perform hands-on exploration of the login interface.
2. **Document verified behavior**: Record actual UI layouts, navigation, and validation behaviors.
3. **Identify test conditions**: Define the scenarios and conditions to be covered.
4. **Design test cases**: Write detailed, step-by-step test cases.
5. **Review test cases**: Review designed test cases to ensure correct test coverage.
6. **Prepare test data**: List and organize valid/invalid credentials for the test execution.
7. **Execute test cases manually**: Run the test cases step-by-step on the active environment.
8. **Record actual results**: Log actual outcomes alongside pass/fail/block statuses.
9. **Capture evidence where appropriate**: Take screenshots to document failed test steps.
10. **Report reproducible defects**: Create individual reports for verified, repeatable bugs.
11. **Retest fixes where applicable**: Validate fixed items against the original failing steps.
12. **Perform regression testing where applicable**: Run sanity/regression tests to ensure no new defects were introduced.
13. **Prepare the Login test summary**: Aggregate run metrics, pass rates, and bug statuses into a final report.
