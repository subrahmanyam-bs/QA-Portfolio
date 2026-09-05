# OrangeHRM Admin Module Test Execution Log

This document records the manual test execution details, actual results, and screenshot evidence for the OrangeHRM Admin (User Management) Module.

---

## 1. Execution Overview
* **Execution Date**: 2026-08-22 (TC-ADMIN-001 to TC-ADMIN-011); 2026-09-05 (TC-ADMIN-012)
* **Execution Method**: Manual execution using Chromium browser (TC-ADMIN-001 to TC-ADMIN-011). TC-ADMIN-012 was executed via a scripted Playwright browser session against the live public demo — a real browser, real requests, real responses, just driven by code instead of by hand, added specifically to probe a gap (special-character/injection-style input) this suite hadn't covered yet.
* **Operating System**: Windows 11
* **Execution Status**: 12 Executed, 11 Passed, 1 Failed, 0 Blocked
* **Pass Rate**: 91.7%

---

## 2. Environment Specifications
* **Target Environment**: Public Demo Instance (`https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`)
* **Test Credentials**: 
  * Username: `Admin`
  * Password: `Public demo credential`
* **Test Data State**: Shared public database. Real-time entries (e.g. employee lookups) are generated dynamically by querying available employee names containing `"a"` to select active user profiles.

---

## 3. Execution Summary Table

| Test Case ID | Test Condition | Description | Status | Evidence / Screenshots |
| :--- | :--- | :--- | :---: | :--- |
| **TC-ADMIN-001** | LC-AD-001, LC-AD-003 | Verify Admin sub-navigation menu headers and search filter fields layout. | **PASS** | [TC-ADMIN-001-navigation.png](screenshots/TC-ADMIN-001-navigation.png) |
| **TC-ADMIN-002** | LC-AD-002 | Verify Add System User form fields and placeholders visibility. | **PASS** | [TC-ADMIN-002-add-user-layout.png](screenshots/TC-ADMIN-002-add-user-layout.png) |
| **TC-ADMIN-003** | LC-AD-004 | Verify validation warnings on Add User form when submitting blank fields. | **PASS** | Warnings verified under 6 inputs |
| **TC-ADMIN-004** | LC-AD-005 | Verify Employee Name autocomplete lookups reject invalid entries. | **PASS** | Autocomplete rejected invalid lookups |
| **TC-ADMIN-005** | LC-AD-006 | Verify credentials validation warnings on passwords. | **PASS** | Checked length and mismatch warnings |
| **TC-ADMIN-006** | LC-AD-007 | Verify successful user creation when all details are valid. | **PASS** | Created system user account successfully |
| **TC-ADMIN-007** | LC-AD-008 | Verify filtering System Users grid by exact Username. | **PASS** | [TC-ADMIN-007-search-results.png](screenshots/TC-ADMIN-007-search-results.png) |
| **TC-ADMIN-008** | LC-AD-009 | Verify filtering System Users grid by User Role and Status. | **PASS** | Filter query returned correct match |
| **TC-ADMIN-009** | LC-AD-010 | Verify Reset button clears search filter fields. | **PASS** | Input fields cleared successfully |
| **TC-ADMIN-010** | LC-AD-011 | Verify successful deletion of selected system user record. | **PASS** | [TC-ADMIN-010-user-deleted.png](screenshots/TC-ADMIN-010-user-deleted.png) |
| **TC-ADMIN-011** | LC-AD-012 | Verify duplicate Username registration rejection validation. | **PASS** | Duplicate rejected with 'Already exists' |
| **TC-ADMIN-012** | LC-AD-013 | Verify Username field rejects unsafe special characters. | **FAIL** ([BUG-ADMIN-001](../bug-reports/BUG-ADMIN-001-username-accepts-unrestricted-characters.md)) | [BUG-ADMIN-001-username-created.png](screenshots/BUG-ADMIN-001-username-created.png) |

---

## 4. Detailed Execution Log

### TC-ADMIN-001: Verify Admin Sub-Navigation Menu Headers and Search Filters Layout
* **Preconditions**: User logged in as Admin, Admin Dashboard loaded.
* **Actual Result**: 
  * Navigation sub-menus detected: `['User Management', 'Job', 'Organization', 'Qualifications', 'Nationalities', 'Corporate Branding', 'Configuration']`.
  * Search filter fields detected: `['Username', 'User Role', 'Employee Name', 'Status']`.
* **Screenshot**: `test-execution/screenshots/TC-ADMIN-001-navigation.png`
* **Status**: **PASS**

---

### TC-ADMIN-002: Verify Add System User Form Fields and Placeholders Visibility
* **Preconditions**: User on System Users page. Add User form loaded.
* **Actual Result**: 
  * The User Role, Employee Name autocomplete input, Status, Username, Password, and Confirm Password fields are visible. Retrieved dynamic employee name: `'A8DCo 4Ys 010Z'`.
* **Screenshot**: `test-execution/screenshots/TC-ADMIN-002-add-user-layout.png`
* **Status**: **PASS**

---

### TC-ADMIN-003: Verify Required Field Validation Warnings on Blank Submission
* **Preconditions**: User on Add User page. Form fields left empty.
* **Actual Result**: 
  * Clicked Save. Red validation warning messages displaying `"Required"` appeared below User Role, Employee Name, Status, Username, Password, and Confirm Password (total of 6 warnings).
* **Status**: **PASS**

---

### TC-ADMIN-004: Verify Autocomplete Lookup Validation on Employee Name
* **Preconditions**: User on Add User page.
* **Actual Result**: 
  * Inputted invalid string `"NonExistentEmployee"`. Autocomplete hints dropdown remained empty, and a red validation warning message displaying `"Invalid"` appeared below the Employee Name input. Inputting the valid demo name cleared the error.
* **Status**: **PASS**

---

### TC-ADMIN-005: Verify Validation Alerts for Weak Passwords and Mismatches
* **Preconditions**: User on Add User page.
* **Actual Result**: 
  * Populated valid User Role, Status, and Username. Inputted `"abc"` in Password and `"xyz"` in Confirm Password. Clicking Save triggered the warnings: `"Should have at least 7 characters"` and `"Passwords do not match"`.
* **Status**: **PASS**

---

### TC-ADMIN-006: Verify Successful System User Creation with Valid Details
* **Preconditions**: User on Add User page.
* **Actual Result**: 
  * Populated all mandatory fields with valid options (Username: `'usr_396949'`, Password: `'admin12345'`). Clicking Save redirected successfully to `/admin/viewSystemUsers`.
* **Status**: **PASS**

---

### TC-ADMIN-007: Verify Filtering System Users Grid by Exact Username
* **Preconditions**: User on System Users page.
* **Actual Result**: 
  * Inputted the dynamically created username `'usr_396949'` inside the Username filter and click Search. The results grid reloaded showing exactly `1` row matching the username.
* **Screenshot**: `test-execution/screenshots/TC-ADMIN-007-search-results.png`
* **Status**: **PASS**

---

### TC-ADMIN-008: Verify Filtering System Users Grid by User Role and Status Dropdowns
* **Preconditions**: User on System Users page.
* **Actual Result**: 
  * Selected User Role as `Admin` and Status as `Enabled` in filters, and clicked Search. The results grid updated showing matches.
* **Status**: **PASS**

---

### TC-ADMIN-009: Verify Reset Button Clears Search Filter Card Fields
* **Preconditions**: User on System Users page.
* **Actual Result**: 
  * Populated Username filter with `'usr_396949'`. Clicked the Reset button (generic button locator). The Username input was cleared back to an empty string.
* **Status**: **PASS**

---

### TC-ADMIN-010: Verify Successful Deletion of System User from List Grid
* **Preconditions**: User on System Users page.
* **Actual Result**: 
  * Filtered by username `'usr_396949'`, checked the row checkbox, clicked the Delete Selected button, and clicked Yes in the confirmation modal. Re-querying returned `0` records.
* **Screenshot**: `test-execution/screenshots/TC-ADMIN-010-user-deleted.png`
* **Status**: **PASS**

---

### TC-ADMIN-011: Verify Duplicate Username Rejection Validation
* **Preconditions**: User on Add User page.
* **Actual Result**: 
  * Inputted duplicate username `"Admin"`. The input field triggered the warning: `"Already exists"`.
* **Status**: **PASS**

---

### TC-ADMIN-012: Verify Username Field Rejects Unsafe Special Characters
* **Preconditions**: User on Add User page.
* **Actual Result**: 
  * Selected a valid User Role, Employee Name, and Status. Entered `' OR '1'='1` in the Username field along with a valid strong password, and clicked Save. No validation error appeared on the Username field itself; the form submitted successfully ("Success: Successfully Saved"). The account appeared in the System Users grid with that exact string as its username, and logging out and back in with it (same password) reached the Dashboard normally.
  * The value was not executed as SQL — it was stored and matched as a literal string with no errors or side effects, so this is a missing-input-validation defect rather than a SQL-injection vulnerability. See [BUG-ADMIN-001](../bug-reports/BUG-ADMIN-001-username-accepts-unrestricted-characters.md) for the full write-up.
  * The test account was deleted immediately after verification.
* **Screenshot**: `test-execution/screenshots/BUG-ADMIN-001-username-created.png`, `test-execution/screenshots/BUG-ADMIN-001-login-success.png`
* **Status**: **FAIL**
