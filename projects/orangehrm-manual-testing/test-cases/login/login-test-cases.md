# OrangeHRM Manual Test Cases - Login Module

This document outlines the detailed manual test cases designed for the OrangeHRM Login Module. These test cases are derived from the approved Login Module Test Conditions.

---

## TC-LOGIN-001: Verify Login Page UI Elements Presence and Visibility

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-001 |
| Test Condition | LC-001 |
| Module | Login |
| Priority | High |
| Type | UI |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Navigate to the OrangeHRM login URL. | Page loads successfully. The URL is verified as `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login` and page title is "OrangeHRM". |
| 2 | Visually inspect the loaded page layout and verify the presence of core UI components. | The following elements are present and visible on screen:; Username input field; Password input field; "Login" button; "Forgot your password?" link text; Branding Logo image; Branding Banner image |

---

## TC-LOGIN-002: Verify Password Masking and Visibility Control Availability

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-002 |
| Test Condition | LC-002, LC-003 |
| Module | Login |
| Priority | High |
| Type | UI |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Focus on the Password input field and type `Valid Demo Admin Password`. | Characters entered into the Password field are masked dynamically (rendered as dots/asterisks). |
| 2 | Inspect the Password input field container for any eye icon or visual toggle control. | Verify if any password visibility toggle is present. (Exploratory observation verified that no toggle control element is present in the password container). |

---

## TC-LOGIN-003: Verify Required Field Validation for Empty and Partial Inputs

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-003 |
| Test Condition | LC-004, LC-005, LC-006 |
| Module | Login |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Username: `Valid Demo Admin Username`; Password: `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Ensure both Username and Password fields are blank, then click the "Login" button. | Form submission fails. The message "Required" is displayed in red text directly below both the Username and Password fields. The URL remains `/web/index.php/auth/login`. |
| 2 | Enter `Valid Demo Admin Username` in the Username field, leave Password blank, and click "Login". | Form submission fails. The message "Required" is displayed below the Password field only. The Username warning disappears. |
| 3 | Clear the Username field, enter `Valid Demo Admin Password` in the Password field, and click "Login". | Form submission fails. The message "Required" is displayed below the Username field only. The Password warning disappears. |

---

## TC-LOGIN-004: Verify Input Field Whitespace Trimming Behavior

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-004 |
| Test Condition | LC-007 |
| Module | Login |
| Priority | Medium |
| Type | Validation |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Username: `  Admin  ` (valid username padded with leading and trailing spaces); Password: `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter the whitespace-padded Username and `Valid Demo Admin Password` in the fields. | Input characters are accepted. |
| 2 | Click the "Login" button. | The application should fail the login attempt and display an "Invalid credentials" warning message if the system does not automatically trim whitespaces. (Note: System behavior is observed to treat whitespace characters literally). |

---

## TC-LOGIN-005: Verify Input Field Special Character Handling

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-005 |
| Test Condition | LC-008 |
| Module | Login |
| Priority | Medium |
| Type | Validation |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Username: `Admin!@#`; Password: `pass$%^` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter special characters in both the Username and Password fields. | Inputs are accepted into fields without blocking or crashing the UI. |
| 2 | Click the "Login" button. | The application should reject the credentials and display the standard "Invalid credentials" error banner. The system must handle the characters gracefully without page rendering distortions or server crashes. |

---

## TC-LOGIN-006: Verify Boundary-Length Handling on Login Inputs

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-006 |
| Test Condition | LC-009 |
| Module | Login |
| Priority | Medium |
| Type | Validation |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Exceedingly long character string (e.g., 100+ characters) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Copy/paste or enter the 100+ character string into the Username field and verify if character limits are enforced. | The Username field should accept or truncate the input. (Note: Field is observed to accept 150 characters without errors). |
| 2 | Repeat Step 1 for the Password field. | The Password field should accept or truncate the input. (Note: Field is observed to accept 150 characters without errors). |
| 3 | Click the "Login" button. | The application handles the submission cleanly, showing the standard "Invalid credentials" warning without UI alignment distortion or system crashes. |

---

## TC-LOGIN-007: Verify Clipboard Operations (Copy/Paste) on Inputs

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-007 |
| Test Condition | LC-010 |
| Module | Login |
| Priority | Medium |
| Type | Usability |
| Preconditions | The user has credentials available in a clipboard text editor. |
| Test Data | Username: `Valid Demo Admin Username`; Password: `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Copy the `Valid Demo Admin Username` from the editor, right-click inside the Username field, and select Paste. | The username value is successfully pasted into the field. |
| 2 | Copy the `Valid Demo Admin Password`, right-click inside the Password field, and select Paste. | The password value is pasted and masked dynamically. |
| 3 | Attempt to copy text out of the Password field (select masked characters -> Ctrl+C). | Browser-level security protocols should restrict copy operations from the password field (copying must not place plain-text password characters onto the clipboard). |

---

## TC-LOGIN-008: Verify Successful Authentication with Valid Credentials

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-008 |
| Test Condition | LC-011, LC-017 |
| Module | Login |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the OrangeHRM login page and has active demo credentials. |
| Test Data | Username: `Valid Demo Admin Username`; Password: `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter `Valid Demo Admin Username` and `Valid Demo Admin Password` in their respective fields. | Characters are entered correctly and password masking is active. |
| 2 | Click the "Login" button. | Authentication succeeds. The user is redirected to the dashboard URL: `https://opensource-demo.orangehrmlive.com/web/index.php/dashboard/index`. Page heading "Dashboard" and main navigation menu are displayed. |

---

## TC-LOGIN-009: Verify Failed Authentication with Invalid Credentials

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-009 |
| Test Condition | LC-012, LC-013, LC-014, LC-018 |
| Module | Login |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Scenario A: `Invalid Username` + `Invalid Password`; Scenario B: `Valid Demo Admin Username` + `Invalid Password`; Scenario C: `Invalid Username` + `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter `Invalid Username` and `Invalid Password` in the fields, and click "Login". | Login fails. An orange alert banner displaying the text "Invalid credentials" appears at the top of the form. The URL remains `/web/index.php/auth/login`. |
| 2 | Clear fields, enter `Valid Demo Admin Username` and `Invalid Password`, and click "Login". | Login fails. General "Invalid credentials" error banner is displayed. URL remains `/web/index.php/auth/login`. |
| 3 | Clear fields, enter `Invalid Username` and `Valid Demo Admin Password`, and click "Login". | Login fails. General "Invalid credentials" error banner is displayed. URL remains `/web/index.php/auth/login`. |

---

## TC-LOGIN-010: Verify Credentials Case Sensitivity

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-010 |
| Test Condition | LC-015 |
| Module | Login |
| Priority | Medium |
| Type | Functional |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Username: `admin` (lowercase 'a'); Password: `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter the lowercase username `admin` and `Valid Demo Admin Password`. | Inputs are accepted. |
| 2 | Click the "Login" button. | The login attempt should succeed and redirect the user to the Dashboard if the authentication system is case-insensitive; otherwise, it must fail with an "Invalid credentials" banner. (Note: Username is case-insensitive). |

---

## TC-LOGIN-011: Verify Account Lockout Behavior on Repeated Login Failures

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-011 |
| Test Condition | LC-016 |
| Module | Login |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Username: `Valid Demo Admin Username`; Password: `Invalid Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Submit incorrect credentials (`Valid Demo Admin Username` and `Invalid Password`) sequentially multiple times (e.g., 5 attempts). | Each attempt fails, showing "Invalid credentials". |
| 2 | On the next attempt, input correct credentials (`Valid Demo Admin Username` and `Valid Demo Admin Password`) and click "Login". | If an account lockout policy is configured, the application should display an account locked warning and block the login; otherwise, the user should be logged in immediately. (Note: Login succeeds immediately). |

---

## TC-LOGIN-012: Verify Logout Redirection and Form Access

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-012 |
| Test Condition | LC-019 |
| Module | Login |
| Priority | High |
| Type | Navigation |
| Preconditions | The user is authenticated and is on the OrangeHRM dashboard. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click the user dropdown menu tab (`oxd-userdropdown-tab`) in the top navigation bar. | User dropdown menu expands. |
| 2 | Click the "Logout" link. | Redirection succeeds. The user is returned to the login URL: `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`. Login input fields are visible. |

---

## TC-LOGIN-013: Verify Browser Back Button Behavior after Logout

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-013 |
| Test Condition | LC-020 |
| Module | Login |
| Priority | High |
| Type | Navigation |
| Preconditions | The user has logged in successfully and then explicitly logged out. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Log out from the application, returning to the login page. | Redirection succeeds, showing the login screen. |
| 2 | Click the browser's "Back" navigation button. | The Login page is displayed at the login URL. No Dashboard page is displayed during this observation. |

---

## TC-LOGIN-014: Verify Direct Access Restriction to Dashboard

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-014 |
| Test Condition | LC-022 |
| Module | Login |
| Priority | High |
| Type | Session |
| Preconditions | The user does not have an active browser session. |
| Test Data | Target URL: `https://opensource-demo.orangehrmlive.com/web/index.php/dashboard/index` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Clear all browser cookies and cache. | Cookies/session tokens are deleted. |
| 2 | Enter the direct dashboard URL into the browser address bar and press Enter. | The application should block access to the Dashboard and immediately redirect the user back to the login page URL (`/auth/login`) with the login form visible. |

---

## TC-LOGIN-015: Verify Session Persistence on Page Refresh

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-015 |
| Test Condition | LC-023 |
| Module | Login |
| Priority | Medium |
| Type | Session |
| Preconditions | The user is logged in and is on the OrangeHRM dashboard. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | While on the dashboard, click the browser's "Reload/Refresh" button. | The dashboard page reloads successfully. The active user session must persist without prompting for re-authentication. |

---

## TC-LOGIN-016: Verify Session Synchronization Across Browser Tabs

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-016 |
| Test Condition | LC-024 |
| Module | Login |
| Priority | Medium |
| Type | Session |
| Preconditions | The user is logged in and has an active session in the first browser tab. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Open a new browser tab, paste the Dashboard URL, and press Enter. | The Dashboard should load successfully without prompting for credentials, indicating that session cookies are shared across active browser tabs. |
| 2 | In the second tab, log out of the application. | Logout redirect completes, returning the user to the login screen in the second tab. |
| 3 | Return to the first browser tab and click a navigation menu item. | The application should block the navigation, invalidate local view access, and redirect the user to the Login page URL since the session was terminated in the second tab. |

---

## TC-LOGIN-017: Verify Inactivity Session Expiration

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-017 |
| Test Condition | LC-025 |
| Module | Login |
| Priority | Medium |
| Type | Session |
| Preconditions | The user is logged in and is on the OrangeHRM dashboard. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Leave the application idle for a designated period (e.g., 15 minutes, 30 minutes, or longer). | Application remains idle. |
| 2 | After the idle period, attempt to click any navigation link in the menu. | The application should invalidate the session and redirect the user to the Login page. (Note: Expected behavior requires product/requirement clarification regarding the exact idle timeout threshold). |

---

## TC-LOGIN-018: Verify Forgot Password Flow Navigation

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-018 |
| Test Condition | LC-021 |
| Module | Login |
| Priority | Medium |
| Type | Navigation |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Locate and click the "Forgot your password?" link. | The application should navigate to the Reset Password request page URL (`/requestPasswordResetCode`) and render the password recovery username input form. |

---

## TC-LOGIN-019: Verify Keyboard Tab Focus Order and Navigation

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-019 |
| Test Condition | LC-026 |
| Module | Login |
| Priority | Medium |
| Type | Usability |
| Preconditions | The user is on the OrangeHRM login page. Focus is cleared from all inputs. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Press the `Tab` key on the keyboard. | Focus outline indicator shifts to the Username input field. |
| 2 | Press the `Tab` key again. | Focus outline indicator shifts to the Password input field. |
| 3 | Press the `Tab` key again. | Focus outline indicator shifts to the "Login" button. |

---

## TC-LOGIN-020: Verify Enter Key Form Submission

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-020 |
| Test Condition | LC-027 |
| Module | Login |
| Priority | Medium |
| Type | Usability |
| Preconditions | The user is on the OrangeHRM login page. |
| Test Data | Username: `Valid Demo Admin Username`; Password: `Valid Demo Admin Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter values into Username and Password fields. | Inputs are accepted. |
| 2 | With focus remaining inside the Password field, press the `Enter` key on the keyboard. | The form submit action should trigger, authenticating the user and redirecting them to the Dashboard URL `/dashboard/index`. |

---

## TC-LOGIN-021: Verify Screen Resolution UI Rendering Compatibility

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-021 |
| Test Condition | LC-028 |
| Module | Login |
| Priority | Low |
| Type | Compatibility |
| Preconditions | User is viewing the OrangeHRM login page. |
| Test Data | Layout resolution sizes (e.g. 1920x1080, 1366x768, 1024x768, 768x1024) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Adjust screen width to standard desktop sizes and verify login page render scaling. | The login container card should remain centered on the screen, and all elements (inputs, labels, button, logos) must scale cleanly and remain visible without structural overlapping. |

---

## TC-LOGIN-022: Verify Layout Rendering and Behavior Across Supported Browsers

| Field | Value |
|---|---|
| Test Case ID | TC-LOGIN-022 |
| Test Condition | LC-029 |
| Module | Login |
| Priority | Low |
| Type | Compatibility |
| Preconditions | User has access to Chrome, Firefox, Edge, or Safari. |
| Test Data | Target web browsers |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Open the login page URL in Firefox and perform basic empty fields validation. | The login page should load successfully, displaying the standard inputs and branding layout without rendering anomalies or alignment offsets. |
| 2 | Repeat Step 1 using Edge. | The login page should load successfully, displaying the standard inputs and branding layout without rendering anomalies or alignment offsets. |
| 3 | Repeat Step 1 using Safari (if OS is macOS). | The login page should load successfully, displaying the standard inputs and branding layout without rendering anomalies or alignment offsets. |

---

## Test Condition Traceability

The following matrix maps the approved Login Module Test Conditions to their corresponding detailed test cases:

| Condition ID | Test Case IDs | Notes / Comments |
|---|---|---|
| **LC-001** | TC-LOGIN-001 | Covers visibility and presence of core login elements. |
| **LC-002** | TC-LOGIN-002 | Covers password character masking. |
| **LC-003** | TC-LOGIN-001, TC-LOGIN-002 | Covers presence and check for password visibility controls. |
| **LC-004** | TC-LOGIN-003 | Covers blank fields validation. |
| **LC-005** | TC-LOGIN-003 | Covers blank password warning. |
| **LC-006** | TC-LOGIN-003 | Covers blank username warning. |
| **LC-007** | TC-LOGIN-004 | Covers whitespace trimming behavior. |
| **LC-008** | TC-LOGIN-005 | Covers special character entries. |
| **LC-009** | TC-LOGIN-006 | Covers boundary-length inputs. |
| **LC-010** | TC-LOGIN-007 | Covers clipboard copy/paste actions. |
| **LC-011** | TC-LOGIN-008 | Covers authentication using valid inputs. |
| **LC-012** | TC-LOGIN-009 | Covers authentication failures on incorrect inputs. |
| **LC-013** | TC-LOGIN-009 | Covers valid username + invalid password validation. |
| **LC-014** | TC-LOGIN-009 | Covers invalid username + valid password validation. |
| **LC-015** | TC-LOGIN-010 | Covers case-sensitivity properties of credentials. |
| **LC-016** | TC-LOGIN-011 | Covers repeated failures and account lockout. |
| **LC-017** | TC-LOGIN-008 | Covers redirect coordinates on success. |
| **LC-018** | TC-LOGIN-009 | Covers static page URL locking on error. |
| **LC-019** | TC-LOGIN-012 | Covers redirection after explicit logouts. |
| **LC-020** | TC-LOGIN-013 | Covers Back button behavior post-logout. |
| **LC-021** | TC-LOGIN-018 | Covers password recovery redirects. |
| **LC-022** | TC-LOGIN-014 | Covers direct dashboard deep-link restrictions. |
| **LC-023** | TC-LOGIN-015 | Covers session persistence on page refresh. |
| **LC-024** | TC-LOGIN-016 | Covers session sync and dropdown logouts in multi-tab browsing. |
| **LC-025** | TC-LOGIN-017 | Covers inactivity idle timeout rules. |
| **LC-026** | TC-LOGIN-019 | Covers tab index focus changes. |
| **LC-027** | TC-LOGIN-020 | Covers Enter key submit bindings. |
| **LC-028** | TC-LOGIN-021 | Covers responsive rendering scale compatibility. |
| **LC-029** | TC-LOGIN-022 | Covers multi-browser formatting compatibility. |

---

## Test Case Summary

Below is the design-time summary of the created manual test suite:

### Priority Distribution
* **High Priority**: 9 test cases
* **Medium Priority**: 11 test cases
* **Low Priority**: 2 test cases
* **Total Test Cases**: `22`

### Test Type Distribution
* **UI**: 2 test cases
* **Validation**: 4 test cases
* **Functional**: 4 test cases
* **Navigation**: 4 test cases
* **Session**: 4 test cases
* **Usability**: 2 test cases
* **Compatibility**: 2 test cases
