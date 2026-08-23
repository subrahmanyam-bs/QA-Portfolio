# OrangeHRM Manual Test Cases - Admin Module

This document outlines the detailed manual test cases designed for the OrangeHRM Admin (User Management) Module. These test cases are derived from the identified Admin Test Conditions.

---

## TC-ADMIN-001: Verify Admin Sub-Navigation Menu Headers and Search Filters Layout

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-001 |
| Test Condition | LC-AD-001, LC-AD-003 |
| Module | Admin |
| Priority | High |
| Type | UI |
| Preconditions | The user is logged in as Admin and is on the Admin System Users page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Visually inspect the topbar sub-navigation menu headers on the Admin dashboard. | The following sub-menus are visible:; User Management (dropdown); Job (dropdown); Organization (dropdown); Qualifications (dropdown); Nationalities; Corporate Branding; Configuration (dropdown) |
| 2 | Visually inspect the "System Users" filter card container elements. | The following filter fields are visible:; Username (text input); User Role (dropdown selector); Employee Name (autocomplete text input); Status (dropdown selector); "Reset" button (white outline); "Search" button (green fill) |

---

## TC-ADMIN-002: Verify Add System User Form Fields and Placeholders Visibility

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-002 |
| Test Condition | LC-AD-002 |
| Module | Admin |
| Priority | High |
| Type | UI |
| Preconditions | The user is logged in as Admin and is on the Admin System Users page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click on the "Add" button above the table results grid. | Redirection succeeds. The URL is `/web/index.php/admin/saveSystemUser` and a card titled "Add User" is loaded. |
| 2 | Visually inspect the input fields and elements available on the form. | The following fields are visible with correct layout alignment:; "User Role" dropdown selector (default: "-- Select --"); "Employee Name" autocomplete input (placeholder: "Type for hints..."); "Status" dropdown selector (default: "-- Select --"); "Username" text input field; "Password" password input field (masked); "Confirm Password" password input field (masked); "Cancel" button (white outline); "Save" button (green fill) |

---

## TC-ADMIN-003: Verify Required Field Validation Warnings on Blank Submission

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-003 |
| Test Condition | LC-AD-004 |
| Module | Admin |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Add User" page. Form fields are completely clear. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Leave the User Role, Employee Name, Status, Username, Password, and Confirm Password fields blank. | Inputs are empty. |
| 2 | Click the "Save" button. | Submission fails. A red text message displaying "Required" appears immediately below all 6 inputs on the card. |

---

## TC-ADMIN-004: Verify Autocomplete Lookup Validation on Employee Name

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-004 |
| Test Condition | LC-AD-005 |
| Module | Admin |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Add User" page. |
| Test Data | Invalid Employee Name: `NonExistentEmployee`; Valid Employee Name: `Jane Marie Doe` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Focus the "Employee Name" input, type `NonExistentEmployee`, and wait for autocomplete hints. | Autocomplete suggestions dropdown does not display options. |
| 2 | Click out of the field or click Save. | A red validation error displaying "Invalid" appears directly below the Employee Name input field. |
| 3 | Clear the input, type `Jane Marie Doe`, and select the name from the autocomplete dropdown menu. | The warning message disappears and the valid name is accepted. |

---

## TC-ADMIN-005: Verify Validation Alerts for Weak Passwords and Mismatches

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-005 |
| Test Condition | LC-AD-006 |
| Module | Admin |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Add User" page. |
| Test Data | Short Password: `abc` (under 8 characters); Confirm Password: `xyz` (mismatched confirmation) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Fill out a valid User Role, Employee Name, Status, and Username. | Values are entered. |
| 2 | Enter `abc` in Password, enter `xyz` in Confirm Password, and click Save. | Submission fails. Red validation warning messages are displayed:; Below Password: "Should have at least 7 characters" (or similar strength warning); Below Confirm Password: "Passwords do not match" |

---

## TC-ADMIN-006: Verify Successful System User Creation with Valid Details

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-006 |
| Test Condition | LC-AD-007 |
| Module | Admin |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the "Add User" page. |
| Test Data | User Role: `Admin`; Employee Name: `Jane Marie Doe`; Status: `Enabled`; Username: `test_user_admin1` (unique dynamic username); Password: `Valid User Password`; Confirm Password: `Valid User Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Select User Role `Admin`, select Employee Name `Jane Marie Doe`, and select Status `Enabled`. | Options are selected. |
| 2 | Input `test_user_admin1` in Username, input `Valid User Password` in Password, and matching confirmation string. | Inputs are accepted. |
| 3 | Click the "Save" button. | User creation succeeds. The user is redirected to the System Users dashboard list (URL contains `/admin/viewSystemUsers`). A green success toast notification "Successfully Saved" is displayed. |

---

## TC-ADMIN-007: Verify Filtering System Users Grid by Exact Username

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-007 |
| Test Condition | LC-AD-008 |
| Module | Admin |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the System Users page. A user account with Username `test_user_admin1` exists in the system. |
| Test Data | Username filter: `test_user_admin1` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Focus the "Username" input field inside the search card, and type `test_user_admin1`. | Username is typed. |
| 2 | Click the "Search" button. | The results table reloads, displaying exactly the row matching username `test_user_admin1` in the grid. |

---

## TC-ADMIN-008: Verify Filtering System Users Grid by User Role and Status Dropdowns

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-008 |
| Test Condition | LC-AD-009 |
| Module | Admin |
| Priority | Medium |
| Type | Functional |
| Preconditions | The user is on the System Users page. |
| Test Data | User Role dropdown selection: `Admin`; Status dropdown selection: `Enabled` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click the "User Role" dropdown, select `Admin`, and click "Search". | The results table reloads, displaying only user records with the `Admin` role. |
| 2 | Click "Reset". Click the "Status" dropdown, select `Enabled`, and click "Search". | The results table reloads, displaying only active `Enabled` user accounts. |

---

## TC-ADMIN-009: Verify Reset Button Clears Search Filter Card Fields

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-009 |
| Test Condition | LC-AD-010 |
| Module | Admin |
| Priority | Medium |
| Type | Usability |
| Preconditions | The user is on the System Users page. |
| Test Data | Username: `test_user_admin1`; User Role: `Admin`; Status: `Enabled` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Populate Username with `test_user_admin1`, select User Role dropdown as `Admin`, and select Status as `Enabled`. | Fields contain values. |
| 2 | Click the "Reset" button. | The Username input is cleared, dropdown selectors revert to their defaults (e.g., "-- Select --"), and the table reloads the default full system users list. |

---

## TC-ADMIN-010: Verify Successful Deletion of System User from List Grid

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-010 |
| Test Condition | LC-AD-011 |
| Module | Admin |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the System Users page. A user record with Username `test_user_admin1` exists in the table. |
| Test Data | Username to delete: `test_user_admin1` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Input `test_user_admin1` in the Username filter and click "Search". | The single row matching the user is displayed. |
| 2 | Click the checkbox in the left-most column of the user row. | Checkbox is selected. Row is highlighted. |
| 3 | Click the trash icon button in the selected row (or the "Delete Selected" button above the table). | A confirmation modal dialog titled "Are you Sure?" is displayed. |
| 4 | Click the "Yes, Delete" button inside the modal dialog. | The dialog closes, a green toast notification "Successfully Deleted" is displayed, and the table results reload showing "No Records Found". |

---

## TC-ADMIN-011: Verify Duplicate Username Rejection Validation

| Field | Value |
|---|---|
| Test Case ID | TC-ADMIN-011 |
| Test Condition | LC-AD-012 |
| Module | Admin |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Add User" page. An account with Username `Admin` already exists in the system database. |
| Test Data | Duplicate Username: `Admin` (or another existing username) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Select User Role, Employee Name, and Status. | Inputs are selected. |
| 2 | Focus the "Username" input and type `Admin`. Click out of the field or click Save. | Submission fails. A red validation message displaying "Already exists" appears directly below the Username input field. |

---

## Test Condition Traceability

The following matrix maps the Admin Test Conditions to their corresponding test cases:

| Condition ID | Test Case IDs | Notes / Comments |
|---|---|---|
| **LC-AD-001** | TC-ADMIN-001 | Covers sub-navigation headers visibility. |
| **LC-AD-002** | TC-ADMIN-002 | Covers Add User form inputs visibility. |
| **LC-AD-003** | TC-ADMIN-001 | Covers System Users search card layout. |
| **LC-AD-004** | TC-ADMIN-003 | Covers blank mandatory validation checks. |
| **LC-AD-005** | TC-ADMIN-004 | Covers autocomplete employee lookups validation. |
| **LC-AD-006** | TC-ADMIN-005 | Covers password strength and case matching warnings. |
| **LC-AD-007** | TC-ADMIN-006 | Covers successful system user creation. |
| **LC-AD-008** | TC-ADMIN-007 | Covers users list filtering by exact username. |
| **LC-AD-009** | TC-ADMIN-008 | Covers users list filtering by dropdown selections. |
| **LC-AD-010** | TC-ADMIN-009 | Covers Reset button clearing search filters. |
| **LC-AD-011** | TC-ADMIN-010 | Covers checkbox selection and record deletion. |
| **LC-AD-012** | TC-ADMIN-011 | Covers duplicate username rejection alerts. |

---

## Test Case Summary

### Priority Distribution
* **High Priority**: 9 test cases
* **Medium Priority**: 2 test cases
* **Low Priority**: 0 test cases
* **Total Test Cases**: `11`

### Test Type Distribution
* **UI**: 2 test cases
* **Validation**: 4 test cases
* **Functional**: 4 test cases
* **Usability**: 1 test case
