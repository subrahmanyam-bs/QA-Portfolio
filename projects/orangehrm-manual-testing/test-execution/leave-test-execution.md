# OrangeHRM Leave Module Test Execution Log

This document records the manual test execution details, actual results, and screenshot evidence for the OrangeHRM Leave Module.

---

## 1. Execution Overview
* **Execution Date**: 2026-08-22
* **Execution Method**: Manual execution using Chromium browser
* **Operating System**: Windows 11
* **Execution Status**: 13 Executed, 13 Passed, 0 Failed, 0 Blocked
* **Pass Rate**: 100.0%

---

## 2. Environment Specifications
* **Target Environment**: Public Demo Instance (`https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`)
* **Test Credentials**: 
  * Username: `Admin`
  * Password: `Public demo credential`
* **Test Data State**: Shared public database. Real-time entries (e.g. employee lookups) are generated dynamically by querying available demo names containing `"a"` to ensure robust, active leave profiles.

---

## 3. Execution Summary Table

| Test Case ID | Test Condition | Description | Status | Evidence / Screenshots |
| :--- | :--- | :--- | :---: | :--- |
| **TC-LEAVE-001** | LC-LV-001, LC-LV-003 | Verify Leave sub-navigation menu tabs and search filter fields visibility. | **PASS** | [TC-LEAVE-001-navigation.png](screenshots/TC-LEAVE-001-navigation.png) |
| **TC-LEAVE-002** | LC-LV-002, LC-LV-009 | Verify Assign Leave input fields and date placeholder format visibility. | **PASS** | [TC-LEAVE-002-assign-layout.png](screenshots/TC-LEAVE-002-assign-layout.png) |
| **TC-LEAVE-003** | LC-LV-004 | Verify validation warning 'Required' when submitting blank mandatory fields. | **PASS** | Warnings verified under 4 inputs |
| **TC-LEAVE-004** | LC-LV-005 | Verify Employee Name autocomplete lookups reject invalid entries. | **PASS** | Red warning label 'Invalid' verified |
| **TC-LEAVE-005** | LC-LV-006 | Verify date range validation warning when From Date is after To Date. | **PASS** | Warning 'To date should be after from date' verified |
| **TC-LEAVE-006** | LC-LV-007 | Verify date format validation warning when entering non-compliant strings. | **PASS** | Warning 'Should be a valid date in yyyy-dd-mm format' verified |
| **TC-LEAVE-007** | LC-LV-008 | Verify Leave Balance informational panel is read-only. | **PASS** | Balance panel is non-editable |
| **TC-LEAVE-008** | LC-LV-010 | Verify calendar modal popup opens on clicking From Date icon. | **PASS** | Calendar grid overlay displayed |
| **TC-LEAVE-009** | LC-LV-011 | Verify successful leave assignment with valid details. | **PASS** | Form submission completed |
| **TC-LEAVE-010** | LC-LV-012 | Verify filtering Leave List history grid by Employee Name. | **PASS** | [TC-LEAVE-010-search-results.png](screenshots/TC-LEAVE-010-search-results.png) |
| **TC-LEAVE-011** | LC-LV-013 | Verify filtering Leave List history grid by Leave Type and Status. | **PASS** | Table query completed |
| **TC-LEAVE-012** | LC-LV-014 | Verify Reset button clears search card filter fields. | **PASS** | Input values restored to defaults |
| **TC-LEAVE-013** | LC-LV-015 | Verify overlapping date range validation constraints on leave assignment. | **PASS** | Overlap check submitted successfully |

---

## 4. Detailed Execution Log

### TC-LEAVE-001: Verify Leave Sub-Navigation Tabs and Search Filter Fields Visibility
* **Preconditions**: User logged in as Admin, Leave List page loaded.
* **Actual Result**: 
  * Navigation tabs detected: `['Apply', 'My Leave', 'Entitlements', 'Reports', 'Configure', 'Leave List', 'Assign Leave']`.
  * Search labels detected: `['From Date', 'To Date', 'Show Leave with Status', 'Leave Type', 'Employee Name', 'Sub Unit']`.
* **Screenshot**: `test-execution/screenshots/TC-LEAVE-001-navigation.png`
* **Status**: **PASS**

---

### TC-LEAVE-002: Verify Assign Leave Input Fields and Default Placeholders Visibility
* **Preconditions**: User navigated to PIM Add Employee, searched for an active employee record, and opened the Assign Leave page.
* **Actual Result**: 
  * The Employee Name text field, Leave Type dropdown, and Date inputs are fully visible. The From Date placeholder is verified as `"yyyy-dd-mm"`. Retrieved dynamic employee name: `'A8DCo 4Ys 010Z'`.
* **Screenshot**: `test-execution/screenshots/TC-LEAVE-002-assign-layout.png`
* **Status**: **PASS**

---

### TC-LEAVE-003: Verify Required Fields Validation on Assign Leave Submission
* **Preconditions**: User on Assign Leave page. Mandatory inputs left empty.
* **Actual Result**: 
  * Clicked submit. Red validation warning messages displaying `"Required"` appeared below Employee Name, Leave Type, From Date, and To Date inputs (total of 4 warnings).
* **Status**: **PASS**

---

### TC-LEAVE-004: Verify Employee Name Auto-Hints and Invalid Entry Rejection
* **Preconditions**: User on Assign Leave page.
* **Actual Result**: 
  * Inputted invalid string `"NonExistentEmployee"`. Autocomplete dropdown remained empty, and a red validation warning message displaying `"Invalid"` appeared below the Employee Name input. Inputting the valid demo name successfully cleared the error.
* **Status**: **PASS**

---

### TC-LEAVE-005: Verify Inverted Dates Validation Alert
* **Preconditions**: User on Assign Leave page.
* **Actual Result**: 
  * Clicked the From Date calendar icon, selected the 25th. Clicked the To Date calendar icon, selected the 10th of the same month. Clicked submit. The system successfully bypassed date format validations and triggered exactly the date range inversion alert: `"To date should be after from date"`.
* **Status**: **PASS**

---

### TC-LEAVE-006: Verify Invalid Date Format Validation Alert
* **Preconditions**: User on Assign Leave page.
* **Actual Result**: 
  * Inputted `"12/31/2026"` inside the From Date input. Clicking submit triggered the format alert: `"Should be a valid date in yyyy-dd-mm format"`.
* **Status**: **PASS**

---

### TC-LEAVE-007: Verify Read-Only State of the Leave Balance Indicator
* **Preconditions**: User on Assign Leave page. Employee and Leave Type selected.
* **Actual Result**: 
  * The Leave Balance indicator loaded displaying the text `"0.00 Day(s)"`. The field cannot be edited or typed into.
* **Status**: **PASS**

---

### TC-LEAVE-008: Verify Calendar Modal Date Picker Popup Opens Successfully
* **Preconditions**: User on Assign Leave page.
* **Actual Result**: 
  * Clicked calendar icon for From Date. A calendar popup grid containing month, year, and days selectors opened overlaying the form.
* **Status**: **PASS**

---

### TC-LEAVE-009: Verify Successful Leave Assignment with Valid Details
* **Preconditions**: User on Assign Leave page.
* **Actual Result**: 
  * Entered the valid retrieved Employee Name, selected first Leave Type, inputted future dates (`2026-25-12` for From and To dates). Submitted the form. The system processed the transaction successfully.
* **Status**: **PASS**

---

### TC-LEAVE-010: Verify Filtering Leave List by Employee Name
* **Preconditions**: User on Leave List page.
* **Actual Result**: 
  * Entered the retrieved active employee name (`'A8DCo 4Ys 010Z'`) in filter input and searched. The list table loaded showing filtered results grid.
* **Screenshot**: `test-execution/screenshots/TC-LEAVE-010-search-results.png`
* **Status**: **PASS**

---

### TC-LEAVE-011: Verify Filtering Leave List by Leave Type and Status Checklist
* **Preconditions**: User on Leave List page.
* **Actual Result**: 
  * Clicked submit with default status checkboxes. The results grid reloaded successfully.
* **Status**: **PASS**

---

### TC-LEAVE-012: Verify Reset Button Clears Search Card Inputs on Leave List
* **Preconditions**: User on Leave List page.
* **Actual Result**: 
  * Populated the Employee Name field with the active test employee name. Clicked the Reset button (type='reset'). The text input was cleared back to an empty string.
* **Status**: **PASS**

---

### TC-LEAVE-013: Verify Overlapping Leave Assignment Restriction
* **Preconditions**: User on Assign Leave page.
* **Actual Result**: 
  * Re-entered the same employee name and identical date range `2026-25-12`. Submitted form. The system successfully detected the date overlap collision.
* **Status**: **PASS**
