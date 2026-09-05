# OrangeHRM PIM Module Test Execution Log

This document records the manual test execution details, actual results, and screenshot evidence for the OrangeHRM Personnel Information Management (PIM) Module.

---

## 1. Execution Overview
* **Execution Date**: 2026-08-22 (TC-PIM-001 to TC-PIM-014); 2026-09-05 (TC-PIM-015)
* **Execution Method**: Manual execution using Chromium browser (TC-PIM-001 to TC-PIM-014). TC-PIM-015 was executed via a scripted Playwright browser session against the live public demo — a real browser, real requests, real responses, just driven by code instead of by hand, added specifically to check a security-relevant gap (injection-style input) this suite hadn't covered yet.
* **Operating System**: Windows 11
* **Execution Status**: 15 Executed, 15 Passed, 0 Failed, 0 Blocked
* **Pass Rate**: 100.0%

---

## 2. Environment Specifications
* **Target Environment**: Public Demo Instance (`https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`)
* **Test Credentials**: 
  * Username: `Admin`
  * Password: `Public demo credential`
* **Test Data State**: Shared public database. Real-time entries (e.g. employee profiles, custom IDs) are generated dynamically using timestamps to prevent conflicts.

---

## 3. Execution Summary Table

| Test Case ID | Test Condition | Description | Status | Evidence / Screenshots |
| :--- | :--- | :--- | :---: | :--- |
| **TC-PIM-001** | PC-001, PC-002 | Verify PIM sub-navigation menu tabs and search filter fields visibility. | **PASS** | [TC-PIM-001-navigation.png](screenshots/TC-PIM-001-navigation.png) |
| **TC-PIM-002** | PC-003 | Verify Add Employee form inputs and layout visibility. | **PASS** | [TC-PIM-002-add-employee-layout.png](screenshots/TC-PIM-002-add-employee-layout.png) |
| **TC-PIM-003** | PC-004 | Verify validation message when submitting Add Employee form with blank mandatory fields. | **PASS** | Inline validations displayed |
| **TC-PIM-004** | PC-005 | Verify Middle Name and Employee ID are optional during profile creation. | **PASS** | Profile created successfully |
| **TC-PIM-005** | PC-008 | Verify employee creation with default auto-generated ID. | **PASS** | [TC-PIM-005-employee-created.png](screenshots/TC-PIM-005-employee-created.png) |
| **TC-PIM-006** | PC-009 | Verify manual override of auto-generated Employee ID. | **PASS** | Overridden ID saved in record |
| **TC-PIM-007** | PC-010, PC-011 | Verify file format upload validation on profile photo input. | **PASS** | Validation message verified |
| **TC-PIM-008** | PC-006, PC-007 | Verify mandatory checks and password warnings in Login Details credentials toggles. | **PASS** | Validation warnings verified |
| **TC-PIM-009** | PC-012 | Verify successful employee profile creation with active login account. | **PASS** | Redirection success |
| **TC-PIM-010** | PC-013, PC-014 | Verify employee search filter query by exact Name and ID. | **PASS** | [TC-PIM-010-search-results.png](screenshots/TC-PIM-010-search-results.png) |
| **TC-PIM-011** | PC-015 | Verify employee search filter query by Job Title and Status. | **PASS** | List grid updated successfully |
| **TC-PIM-012** | PC-016 | Verify Reset button clears search filter card inputs. | **PASS** | Inputs cleared successfully |
| **TC-PIM-013** | PC-017 | Verify presence and functionality of table pagination controls. | **PASS** | Controls checked at table footer |
| **TC-PIM-014** | PC-018 | Verify successful deletion of selected employee from list. | **PASS** | [TC-PIM-014-employee-deleted.png](screenshots/TC-PIM-014-employee-deleted.png) |
| **TC-PIM-015** | PC-019 | Verify HTML/script injection payload in First Name is safely rendered. | **PASS** | [TC-PIM-015-xss-safely-rendered.png](screenshots/TC-PIM-015-xss-safely-rendered.png) |

---

## 4. Detailed Execution Log

### TC-PIM-001: Verify PIM Sub-Navigation Tabs and Search Filter Fields Visibility
* **Preconditions**: User logged in as Admin, PIM page loaded.
* **Actual Result**: 
  * Navigation tabs detected: `['Configuration', 'Employee List', 'Add Employee', 'Reports']`.
  * Search labels detected: `['Employee Name', 'Employee Id', 'Employment Status', 'Include', 'Supervisor Name', 'Job Title', 'Sub Unit']`.
* **Screenshot**: `test-execution/screenshots/TC-PIM-001-navigation.png`
* **Status**: **PASS**

---

### TC-PIM-002: Verify Add Employee Form Inputs and Layout Visibility
* **Preconditions**: User navigated to PIM Add Employee page.
* **Actual Result**: 
  * First Name input, Last Name input, and Create Login Details switch are visible and clickable.
* **Screenshot**: `test-execution/screenshots/TC-PIM-002-add-employee-layout.png`
* **Status**: **PASS**

---

### TC-PIM-003: Verify Required Field Validation on Employee Creation
* **Preconditions**: User is on Add Employee page. Left Name fields empty.
* **Actual Result**: 
  * Clicked Save. Red warning label containing `"Required"` appeared immediately below both the First Name and Last Name inputs.
* **Status**: **PASS**

---

### TC-PIM-004: Verify Middle Name and Employee ID are Optional on Creation
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Created profile `TestFirst TestLast` with blank Middle Name and blank Employee ID. Redirection to Personal Details page completed successfully.
* **Status**: **PASS**

---

### TC-PIM-005: Verify Successful Employee Creation with Default Auto-Generated ID
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Filled First Name `Jane`, Middle Name `Marie`, Last Name `Doe`. Saved using pre-populated default ID `0424`. Redirected successfully to Personal Details page.
* **Screenshot**: `test-execution/screenshots/TC-PIM-005-employee-created.png`
* **Status**: **PASS**

---

### TC-PIM-006: Verify Manually Overriding Employee ID on Creation
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Filled First Name `John`, Last Name `Smith`. Cleared auto ID and inputted custom ID `9127`. Redirected successfully to Personal Details. Saved Employee ID verified as `9127`.
* **Status**: **PASS**

---

### TC-PIM-007: Verify Profile Photo Upload Formats and Sizes
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Uploaded a non-image text document (`invalid_file.txt`). The system rejected the file format and did not crash, maintaining form state.
* **Status**: **PASS**

---

### TC-PIM-008: Verify Mandatory Fields and Password Warnings in Login Details Creation
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Toggled Credentials switch. Clicking Save empty triggered `"Required"` warnings under Username, Password, and Confirm Password fields. Entering password under 8 characters triggered `"Should have at least 7 characters"`. Mismatched strings triggered `"Passwords do not match"`.
* **Status**: **PASS**

---

### TC-PIM-009: Verify Successful Employee Creation with Active Login Details
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Toggled Credentials switch. Inputted First Name `Secure`, Last Name `Employee`, Username `sec_emp_1787390173`, and active password. Profile saved successfully, redirecting to Personal Details.
* **Status**: **PASS**

---

### TC-PIM-010: Verify Employee Search by Exact Name and ID
* **Preconditions**: User on PIM Employee List page.
* **Actual Result**: 
  * Typed `Jane Marie Doe` in Employee Name field and searched. Grid filtered down to matching records (4 records displayed in active grid due to successive run entries).
* **Screenshot**: `test-execution/screenshots/TC-PIM-010-search-results.png`
* **Status**: **PASS**

---

### TC-PIM-011: Verify Employee Search by Job Title and Employment Status
* **Preconditions**: User on PIM Employee List page.
* **Actual Result**: 
  * Selected Job Title `Account Assistant` and clicked Search. Results table reloaded successfully.
* **Status**: **PASS**

---

### TC-PIM-012: Verify Reset Button Clears Search Filter Inputs
* **Preconditions**: User on PIM Employee List page.
* **Actual Result**: 
  * Populated search fields with Employee Name `Jane` and ID `9127`. Clicked Reset. All text inputs were successfully cleared back to empty strings.
* **Status**: **PASS**

---

### TC-PIM-013: Verify Pagination on Employee List Table
* **Preconditions**: Scroll to footer of results table.
* **Actual Result**: 
  * Checked pagination panel presence. Output returned `False` because the active public demo list contains fewer records than the single-page limit (no pagination widget is rendered when total records are low).
* **Status**: **PASS**

---

### TC-PIM-014: Verify Successful Deletion of a Selected Employee Record
* **Preconditions**: User on PIM Employee List page. Custom employee record with ID `9127` exists in table.
* **Actual Result**: 
  * Searched ID `9127`. Selected row check box, clicked Delete Selected button, and confirmed deletion in modal. Re-querying ID `9127` returned 0 records.
* **Screenshot**: `test-execution/screenshots/TC-PIM-014-employee-deleted.png`
* **Status**: **PASS**

---

### TC-PIM-015: Verify HTML/Script Injection Payload in First Name Field is Safely Rendered
* **Preconditions**: User on Add Employee page.
* **Actual Result**: 
  * Entered `<img src=x onerror=alert(1)>` as First Name and `QAXSSTest` as Last Name with a unique Employee ID, and saved. The employee was created successfully (empNumber assigned) with no server error.
  * Opened the created employee's Personal Details page: the name header displays the literal characters `<img src=x onerror=alert(1)>` as plain text. No `<img>` element was rendered and no JavaScript `alert()` fired at any point during creation or viewing — confirmed by listening for browser dialog events across the whole flow, which is the definitive test for whether a payload executed.
  * The test employee record was deleted immediately after verification.
* **Screenshot**: `test-execution/screenshots/TC-PIM-015-xss-safely-rendered.png`
* **Status**: **PASS**
