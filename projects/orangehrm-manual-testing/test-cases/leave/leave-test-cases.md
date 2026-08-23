# OrangeHRM Manual Test Cases - Leave Module

This document outlines the detailed manual test cases designed for the OrangeHRM Leave Module. These test cases are derived from the identified Leave Test Conditions.

---

## TC-LEAVE-001: Verify Leave Sub-Navigation Tabs and Search Filter Fields Visibility

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-001 |
| Test Condition | LC-LV-001, LC-LV-003 |
| Module | Leave |
| Priority | High |
| Type | UI |
| Preconditions | The user is logged in as Admin and is on the Leave List page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Visually inspect the topbar sub-navigation menu tabs on the Leave dashboard. | The following sub-navigation tabs are visible and clickable:; Apply; My Leave; Entitlements (dropdown); Reports (dropdown); Configure (dropdown); Leave List; Assign Leave |
| 2 | Visually inspect the "Leave List" filter card input controls. | The following filter fields are visible:; From Date (text input with calendar icon); To Date (text input with calendar icon); Show Leave with Status (checklist buttons); Leave Type (dropdown selector); Employee Name (text autocomplete input); Sub Unit (dropdown selector); "Reset" button (white outline); "Search" button (green fill) |

---

## TC-LEAVE-002: Verify Assign Leave Input Fields and Default Placeholders Visibility

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-002 |
| Test Condition | LC-LV-002, LC-LV-009 |
| Module | Leave |
| Priority | High |
| Type | UI |
| Preconditions | The user is logged in as Admin and is on the Leave sub-menu. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click on the "Assign Leave" tab in the sub-menu. | Redirection succeeds. The URL is `/web/index.php/leave/assignLeave` and a card titled "Assign Leave" is loaded. |
| 2 | Visually inspect the fields and placeholders inside the Assign Leave card. | The following input elements are present and visible:; "Employee Name" autocomplete input (placeholder: "Type for hints..."); "Leave Type" dropdown selector (default: "-- Select --"); "Leave Balance" indicator (displays static text "0.00 Day(s)" or similar balance); "From Date" date-input (placeholder: "yyyy-dd-mm"); "To Date" date-input (placeholder: "yyyy-dd-mm"); "Comments" textarea input; "Assign" button (green fill) |

---

## TC-LEAVE-003: Verify Required Fields Validation on Assign Leave Submission

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-003 |
| Test Condition | LC-LV-004 |
| Module | Leave |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Assign Leave" page. Form fields are completely clear. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Leave the Employee Name, Leave Type, From Date, and To Date fields completely blank. | Inputs are empty. |
| 2 | Click the "Assign" button. | Submission fails. A red text message displaying "Required" appears immediately below the following inputs:; Employee Name; Leave Type; From Date; To Date |

---

## TC-LEAVE-004: Verify Employee Name Auto-Hints and Invalid Entry Rejection

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-004 |
| Test Condition | LC-LV-005 |
| Module | Leave |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Assign Leave" page. |
| Test Data | Invalid Employee Name: `NonExistentEmployee`; Valid Employee Name: `Jane Marie Doe` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Focus the "Employee Name" field, type `NonExistentEmployee`, and wait for autocomplete hints. | No autocomplete options are displayed. |
| 2 | Click out of the field or attempt to submit. | The field triggers a red validation message displaying "Invalid" directly below the Employee Name input. |
| 3 | Clear the input, type `Jane Marie Doe`, and select the name from the autocomplete dropdown menu. | The input accepts the valid selection, and the red validation warning disappears. |

---

## TC-LEAVE-005: Verify Inverted Dates Validation Alert

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-005 |
| Test Condition | LC-LV-006 |
| Module | Leave |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Assign Leave" page. A valid Employee Name and Leave Type have been selected. |
| Test Data | Employee Name: `Jane Marie Doe`; Leave Type: Any active leave type (e.g. US - Vacation); From Date: `2026-15-08` (August 15, 2026); To Date: `2026-10-08` (August 10, 2026 - earlier than From Date) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Input the valid Employee Name and select the Leave Type. | Values are accepted. |
| 2 | Input `2026-15-08` in From Date, and input `2026-10-08` in To Date. | Inputs are accepted into the fields. |
| 3 | Click the "Assign" button or focus out. | Submission fails. A red validation message displaying "To date should be after from date" appears immediately below the To Date field. |

---

## TC-LEAVE-006: Verify Invalid Date Format Validation Alert

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-006 |
| Test Condition | LC-LV-007 |
| Module | Leave |
| Priority | Medium |
| Type | Validation |
| Preconditions | The user is on the "Assign Leave" page. |
| Test Data | Invalid Date Format: `12/31/2026` (US Slash format); Correct Date Format: `2026-31-12` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Input `12/31/2026` inside the From Date input field. | Input string is accepted. |
| 2 | Click the "Assign" button or click out of the field. | Submission fails. A red validation warning message displaying "Should be a valid date in yyyy-dd-mm format" appears directly below the From Date field. |
| 3 | Clear the input, type `2026-31-12`, and click out. | The validation warning message disappears. |

---

## TC-LEAVE-007: Verify Read-Only State of the Leave Balance Indicator

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-007 |
| Test Condition | LC-LV-008 |
| Module | Leave |
| Priority | Medium |
| Type | Functional |
| Preconditions | The user is on the "Assign Leave" page. |
| Test Data | Employee Name: `Jane Marie Doe`; Leave Type: US - Vacation |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Select Employee Name `Jane Marie Doe` and select Leave Type `US - Vacation`. | The Leave Balance indicator displays the active numeric balance (e.g. "0.00 Day(s)" or similar count). |
| 2 | Try to click, edit, or type characters inside the "Leave Balance" display area. | The balance text cannot be focused, clicked, or edited (the field is strictly read-only and serves as an informational panel only). |

---

## TC-LEAVE-008: Verify Calendar Modal Date Picker Popup Opens Successfully

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-008 |
| Test Condition | LC-LV-010 |
| Module | Leave |
| Priority | Low |
| Type | Usability |
| Preconditions | The user is on the "Assign Leave" page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Locate and click on the calendar icon button inside the From Date input field. | A grid calendar modal overlay opens directly below the input field, showing year, month dropdown selectors, and days grid. |
| 2 | Click on a specific day in the calendar grid (e.g., August 25). | The calendar modal closes, and the clicked date value is automatically populated into the input field in the correct `yyyy-dd-mm` format. |

---

## TC-LEAVE-009: Verify Successful Leave Assignment with Valid Details

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-009 |
| Test Condition | LC-LV-011 |
| Module | Leave |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the "Assign Leave" page. An active employee record (e.g. `Jane Marie Doe`) exists in the database. |
| Test Data | Employee Name: `Jane Marie Doe`; Leave Type: US - Vacation; From Date: `2026-25-08`; To Date: `2026-25-08` (Single day leave); Comments: `Assigned for annual validation testing` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter `Jane Marie Doe` in Employee Name, and select Leave Type `US - Vacation`. | Selected options are displayed. |
| 2 | Input `2026-25-08` in From Date and `2026-25-08` in To Date. Add comment `Assigned for annual validation testing`. | Inputs are accepted. |
| 3 | Click the "Assign" button. | The form submits successfully. If an entitlement balance check is satisfied or bypassed by admin, the page updates showing a green toast notification "Successfully Assigned" (or similar confirmation message). |

---

## TC-LEAVE-010: Verify Filtering Leave List by Employee Name

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-010 |
| Test Condition | LC-LV-012 |
| Module | Leave |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the "Leave List" page. At least one leave record exists in the system. |
| Test Data | Employee Name: `Jane Marie Doe` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Focus the "Employee Name" filter input, type `Jane Marie Doe`, and select it from the autocomplete hints. | The selected employee name is displayed in the input field. |
| 2 | Click the "Search" button. | The results grid reloads, displaying only the leave records assigned to `Jane Marie Doe`. |

---

## TC-LEAVE-011: Verify Filtering Leave List by Leave Type and Status Checklist

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-011 |
| Test Condition | LC-LV-013 |
| Module | Leave |
| Priority | Medium |
| Type | Functional |
| Preconditions | The user is on the "Leave List" page. |
| Test Data | Leave Type selection: `US - Vacation`; Status: "Pending Approval" |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click the "Leave Type" dropdown, select `US - Vacation`. | Selection is displayed in dropdown. |
| 2 | In the "Show Leave with Status" checklist row, toggle the status options such that only "Pending Approval" (or another active status) is checked. | Non-target status buttons are unchecked. |
| 3 | Click the "Search" button. | The results grid updates, showing only records matching the selected Leave Type and active Status filter. |

---

## TC-LEAVE-012: Verify Reset Button Clears Search Card Inputs on Leave List

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-012 |
| Test Condition | LC-LV-014 |
| Module | Leave |
| Priority | Medium |
| Type | Usability |
| Preconditions | The user is on the "Leave List" page. |
| Test Data | Employee Name: `Jane Marie Doe`; From Date: `2026-01-08`; Leave Type: `US - Vacation` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter `Jane Marie Doe` in Employee Name, enter `2026-01-08` in From Date, and select the Leave Type. | Values are inputted. |
| 2 | Click the "Reset" button. | The Employee Name and Date inputs are cleared, dropdown selectors revert to their defaults, and the table loads the default, unfiltered leave history list. |

---

## TC-LEAVE-013: Verify Overlapping Leave Assignment Restriction

| Field | Value |
|---|---|
| Test Case ID | TC-LEAVE-013 |
| Test Condition | LC-LV-015 |
| Module | Leave |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Assign Leave" page. An employee record (e.g. `Jane Marie Doe`) has an active leave scheduled on `2026-25-08`. |
| Test Data | Employee Name: `Jane Marie Doe`; Leave Type: `US - Vacation`; From Date: `2026-25-08` (same date); To Date: `2026-25-08` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter `Jane Marie Doe` in Employee Name, select Leave Type, and enter `2026-25-08` in From/To dates. | Values are entered. |
| 2 | Click the "Assign" button. | Submission fails. The system should detect the date overlap collision and display an error message overlay (e.g., "Overlapping Leave Details Found" or similar error alert). |

---

## Test Condition Traceability

The following matrix maps the Leave Test Conditions to their corresponding test cases:

| Condition ID | Test Case IDs | Notes / Comments |
|---|---|---|
| **LC-LV-001** | TC-LEAVE-001 | Covers Leave topbar navigation menu tabs. |
| **LC-LV-002** | TC-LEAVE-002 | Covers Assign Leave input selectors visibility. |
| **LC-LV-003** | TC-LEAVE-001 | Covers Leave List search filter card inputs. |
| **LC-LV-004** | TC-LEAVE-003 | Covers blank required field validations. |
| **LC-LV-005** | TC-LEAVE-004 | Covers employee name validation alerts. |
| **LC-LV-006** | TC-LEAVE-005 | Covers date range inversion check validation text. |
| **LC-LV-007** | TC-LEAVE-006 | Covers date format template warnings. |
| **LC-LV-008** | TC-LEAVE-007 | Covers read-only state of balance label. |
| **LC-LV-009** | TC-LEAVE-002 | Covers date input yyyy-dd-mm default placeholder text. |
| **LC-LV-010** | TC-LEAVE-008 | Covers popup date picker calendar selection. |
| **LC-LV-011** | TC-LEAVE-009 | Covers successful admin leave assignment. |
| **LC-LV-012** | TC-LEAVE-010 | Covers list dashboard filter query by name. |
| **LC-LV-013** | TC-LEAVE-011 | Covers dropdown select and status checkbox matching. |
| **LC-LV-014** | TC-LEAVE-012 | Covers search card reset actions. |
| **LC-LV-015** | TC-LEAVE-013 | Covers date overlap validation collision check. |

---

## Test Case Summary

### Priority Distribution
* **High Priority**: 8 test cases
* **Medium Priority**: 4 test cases
* **Low Priority**: 1 test case
* **Total Test Cases**: `13`

### Test Type Distribution
* **UI**: 3 test cases
* **Validation**: 5 test cases
* **Functional**: 4 test cases
* **Usability**: 1 test case
