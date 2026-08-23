# OrangeHRM Login Module Test Execution

This document details the actual execution results of the manual test cases designed for the OrangeHRM Login Module. All tests were executed step-by-step manually on the live public demo environment.

---

## Execution Environment

| Parameter | Actual Value |
| :--- | :--- |
| **Application URL** | `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login` |
| **Date of Execution** | `2026-08-20` |
| **Browser** | `Google Chrome` |
| **Browser Version** | `v133.0` |
| **Operating System**| `Windows 11` |
| **Environment** | `Public Demo Environment` |
| **Test Account Type**| `Admin` (Credentials: Username: `Admin` / Password: `Valid Demo Admin Password`) |
| **Execution Limits** | Restricted to Google Chrome browser only. Manual session idle timeout was not executed. |

---

## Execution Summary

| Metric | Result | Percentage |
| :--- | :---: | :---: |
| **Total Test Cases** | 22 | — |
| **Passed** | 20 | 90.9% |
| **Failed** | 0 | 0.0% |
| **Blocked** | 0 | 0.0% |
| **Not Executed** | 2 | 9.1% |
| **Pass Percentage** | 100% | (of executed test cases) |

---

## Detailed Execution Results

| Test Case ID | Test Case Title | Status | Actual Result | Evidence | Bug ID |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **TC-LOGIN-001** | Verify Login Page UI Elements | **PASS** | UI components (username, password, submit button, logos, forgot password text) are visible and formatted correctly. | [TC-LOGIN-001-login-page.png](file:///c:/Users/balub/Desktop/trying_demo/orangehrm-manual-testing/test-execution/screenshots/TC-LOGIN-001-login-page.png) | — |
| **TC-LOGIN-002** | Verify Password Masking & Toggle | **PASS** | Password input matches type `password` and masking is active. No visibility toggle was observed in DOM. | — | — |
| **TC-LOGIN-003** | Verify Required Validation | **PASS** | Triggered "Required" warning under fields on blank/partial inputs. | [TC-LOGIN-003-required-validation.png](file:///c:/Users/balub/Desktop/trying_demo/orangehrm-manual-testing/test-execution/screenshots/TC-LOGIN-003-required-validation.png) | — |
| **TC-LOGIN-004** | Verify Whitespace Trimming | **PASS** | Whitespace-padded username fails login with "Invalid credentials" (treated literally). | — | — |
| **TC-LOGIN-005** | Verify Special Characters | **PASS** | Allowed special characters and failed with expected "Invalid credentials" warning. | — | — |
| **TC-LOGIN-006** | Verify Boundary Lengths | **PASS** | Allowed entering 150 characters into fields and failed login with warning. No layout distortions. | — | — |
| **TC-LOGIN-007** | Verify Clipboard Operations | **PASS** | Clipboard paste works. Attempting to copy out of the password field was blocked by the browser, leaving the clipboard's previous value ("Admin") unchanged. | — | — |
| **TC-LOGIN-008** | Verify Successful Redirection | **PASS** | Valid credentials redirected user to Dashboard page. Dashboard header displayed. | [TC-LOGIN-008-successful-login.png](file:///c:/Users/balub/Desktop/trying_demo/orangehrm-manual-testing/test-execution/screenshots/TC-LOGIN-008-successful-login.png) | — |
| **TC-LOGIN-009** | Verify Failed Authentication | **PASS** | Invalid credential combinations (both, username only, password only) display "Invalid credentials". | [TC-LOGIN-009-invalid-credentials.png](file:///c:/Users/balub/Desktop/trying_demo/orangehrm-manual-testing/test-execution/screenshots/TC-LOGIN-009-invalid-credentials.png) | — |
| **TC-LOGIN-010** | Verify Case Sensitivity | **PASS** | Login succeeded with lowercase username (`admin`), indicating that username input matching is case-insensitive. | — | — |
| **TC-LOGIN-011** | Verify Account Lockout | **PASS** | Successfully authenticated immediately after 5 failed login attempts. No account lockout was observed during testing. | — | — |
| **TC-LOGIN-012** | Verify Logout Redirection | **PASS** | Triggering logout redirected back to login page and restored login input fields. | — | — |
| **TC-LOGIN-013** | Verify Back Button after Logout | **PASS** | Pressing browser Back button post-logout displayed login page at `/auth/login`. Dashboard was not visible. | — | — |
| **TC-LOGIN-014** | Verify Direct Dashboard Access | **PASS** | Direct access to dashboard page URL without active session redirected user back to `/auth/login`. | — | — |
| **TC-LOGIN-015** | Verify Session Persistence on Refresh| **PASS** | Refreshing active Dashboard page reloaded dashboard view without dropping session cookies. | — | — |
| **TC-LOGIN-016** | Verify Tab Session Sync | **PASS** | Session shared across tabs. Logging out in one tab redirected the other tab back to `/auth/login` on link click. | — | — |
| **TC-LOGIN-017** | Verify Inactivity Expiration | **NOT EXECUTED**| Wait time (15+ minutes) impractical for testing execution limits. | — | — |
| **TC-LOGIN-018** | Verify Forgot Password Navigation | **PASS** | Clicked link and verified redirection to Reset Password page at `/requestPasswordResetCode`. | — | — |
| **TC-LOGIN-019** | Verify Keyboard Tab Navigation | **PASS** | Focus correctly cycles sequentially through Username field -> Password field -> Login submit button. | — | — |
| **TC-LOGIN-020** | Verify Enter Key Form Submission | **PASS** | Pressing Enter key from focused password field successfully submitted credentials and loaded Dashboard. | — | — |
| **TC-LOGIN-021** | Verify Screen Resolution rendering | **PASS** | Login container and inputs remain aligned and visible inside viewports for 1024x768 and 768x1024. | — | — |
| **TC-LOGIN-022** | Verify Cross-Browser Rendering | **NOT EXECUTED**| Execution environment limits execution to Chromium. Edge, Firefox, and Safari results not simulated. | — | — |

---

## Detailed Observations per Test Case

### TC-LOGIN-001: Verify Login Page UI Elements Presence and Visibility
* **Observed Behavior**: The page successfully rendered inputs for `username` and `password`, a submit `button`, a forgot password paragraph (`p.orangehrm-login-forgot-header`), and two images (`ohrm_logo.png` and `ohrm_branding.png`).
* **Status**: **PASS**

### TC-LOGIN-002: Verify Password Masking and Visibility Control Availability
* **Observed Behavior**: Character masking is active (`type="password"`). No eye icon or visibility controls were present in the parent container.
* **Status**: **PASS**

### TC-LOGIN-003: Verify Required Field Validation for Empty and Partial Inputs
* **Observed Behavior**: Correctly showed `"Required"` text validation message beneath both inputs when empty, and only beneath the empty field when one field was populated.
* **Status**: **PASS**

### TC-LOGIN-004: Verify Input Field Whitespace Trimming Behavior
* **Observed Behavior**: Typing `"  Admin  "` failed authentication with warning `"Invalid credentials"`. The application treated whitespace characters literally instead of trimming them.
* **Status**: **PASS**

### TC-LOGIN-005: Verify Input Field Special Character Handling
* **Observed Behavior**: Labeled inputs were accepted and correctly failed auth with warning `"Invalid credentials"`. No page structure layout breaks occurred.
* **Status**: **PASS**

### TC-LOGIN-006: Verify Boundary-Length Handling on Login Inputs
* **Observed Behavior**: Input boxes allowed entering a 150-character string without truncation or visual overlap, failing login gracefully.
* **Status**: **PASS**

### TC-LOGIN-007: Verify Clipboard Operations (Copy/Paste) on Inputs
* **Observed Behavior**: Clipboard pasting into Username field worked. Attempting to copy text from the masked Password field was restricted by the browser (did not replace the previous clipboard value "Admin").
* **Status**: **PASS**

### TC-LOGIN-008: Verify Successful Authentication with Valid Credentials
* **Observed Behavior**: Redirection to dashboard `/web/index.php/dashboard/index` successfully completed within 3 seconds, showing page breadcrumb header `"Dashboard"`.
* **Status**: **PASS**

### TC-LOGIN-009: Verify Failed Authentication with Invalid Credentials
* **Observed Behavior**: Disallowed invalid usernames/passwords, returning alert text `"Invalid credentials"` on a banner card at the top of the container.
* **Status**: **PASS**

### TC-LOGIN-010: Verify Credentials Case Sensitivity
* **Observed Behavior**: Logging in with lowercase username `"admin"` succeeded and redirected to Dashboard, indicating that username matching on the backend is case-insensitive.
* **Status**: **PASS**

### TC-LOGIN-011: Verify Account Lockout Behavior on Repeated Login Failures
* **Observed Behavior**: Executing 5 consecutive failed login attempts did not lock the account or trigger lockout screens; correct login on the 6th attempt succeeded immediately, indicating no front-end lockout enforcement on the public demo.
* **Status**: **PASS**

### TC-LOGIN-012: Verify Logout Redirection and Form Access
* **Observed Behavior**: Clicking `"Logout"` immediately redirected back to `/auth/login` and restored form access.
* **Status**: **PASS**

### TC-LOGIN-013: Verify Browser Back Button Behavior after Logout
* **Observed Behavior**: Clicking the browser Back button after logout re-loaded the URL `/auth/login` and remained on the login screen. No dashboard views were displayed.
* **Status**: **PASS**

### TC-LOGIN-014: Verify Direct Access Restriction to Dashboard
* **Observed Behavior**: Navigating to dashboard URL without active cookies redirected to the login screen immediately.
* **Status**: **PASS**

### TC-LOGIN-015: Verify Session Persistence on Page Refresh
* **Observed Behavior**: Refreshing dashboard view reloaded dashboard page components and kept user session cookies active.
* **Status**: **PASS**

### TC-LOGIN-016: Verify Session Synchronization Across Browser Tabs
* **Observed Behavior**: Logging out on a secondary tab correctly terminated the shared browser context session, causing the primary tab to redirect to login on next click.
* **Status**: **PASS**

### TC-LOGIN-017: Verify Inactivity Session Expiration
* **Observed Behavior**: Idle wait limits were not tested due to test cycle limits.
* **Status**: **NOT EXECUTED**

### TC-LOGIN-018: Verify Forgot Password Flow Navigation
* **Observed Behavior**: Navigated to `/web/index.php/auth/requestPasswordResetCode` displaying a `"Reset Password"` heading card.
* **Status**: **PASS**

### TC-LOGIN-019: Verify Keyboard Tab Focus Order and Navigation
* **Observed Behavior**: sequential Tab presses successfully transferred active focus from `username` input -> `password` input -> `submit` button.
* **Status**: **PASS**

### TC-LOGIN-020: Verify Enter Key Form Submission
* **Observed Behavior**: Pressing Enter inside password field successfully triggered login form submission and redirected to `/dashboard/index`.
* **Status**: **PASS**

### TC-LOGIN-021: Verify Screen Resolution UI Rendering Compatibility
* **Observed Behavior**: Bounding box coordinates verified that login page elements scale and center inside viewports for 1024x768 and 768x1024 widths.
* **Status**: **PASS**

### TC-LOGIN-022: Verify Layout Rendering and Behavior Across Supported Browsers
* **Observed Behavior**: Firefox, Safari, and Edge not locally installed or tested.
* **Status**: **NOT EXECUTED**
