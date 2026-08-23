# OrangeHRM Manual Test Cases - PIM Module

This document outlines the detailed manual test cases designed for the OrangeHRM Personnel Information Management (PIM) Module. These test cases are derived from the identified PIM Test Conditions.

---

## TC-PIM-001: Verify PIM Sub-Navigation Tabs and Search Filter Fields Visibility

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-001 |
| Test Condition | PC-001, PC-002 |
| Module | PIM |
| Priority | High |
| Type | UI |
| Preconditions | The user is logged in as Admin and is on the OrangeHRM PIM Employee List page. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Visually inspect the topbar navigation sub-menu tabs on the PIM dashboard. | The following sub-navigation tabs are visible and clickable:; Configuration (dropdown); Employee List; Add Employee; Reports |
| 2 | Visually inspect the "Employee Information" search card container elements. | The following search filter dropdowns and text inputs are present on the card:; Employee Name (text input with auto-hints); Employee Id (text input); Employment Status (dropdown); Include (dropdown, default: "Current Employees Only"); Supervisor Name (text input with auto-hints); Job Title (dropdown); Sub Unit (dropdown); "Reset" button (white outline); "Search" button (green fill) |

---

## TC-PIM-002: Verify Add Employee Form Inputs and Layout Visibility

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-002 |
| Test Condition | PC-003 |
| Module | PIM |
| Priority | High |
| Type | UI |
| Preconditions | The user is logged in as Admin and is on the PIM sub-navigation menu. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click on the "Add Employee" tab in the sub-menu. | Redirection succeeds. The URL is `/web/index.php/pim/addEmployee` and a card titled "Add Employee" is loaded. |
| 2 | Visually inspect the input fields and elements available on the form. | The following input elements are present and visible:; Profile picture file selector wrapper (`type="file"`) with standard photo placeholder; "First Name" text input field; "Middle Name" text input field; "Last Name" text input field; "Employee Id" text input field; "Create Login Details" toggle switch (disabled/off state by default); "Cancel" button (white outline); "Save" button (green fill) |

---

## TC-PIM-003: Verify Required Field Validation on Employee Creation

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-003 |
| Test Condition | PC-004 |
| Module | PIM |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Add Employee" page. Form fields are cleared. |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Leave the "First Name" and "Last Name" fields completely blank. | Input fields are empty. |
| 2 | Click the "Save" button. | Employee creation fails. A red text message displaying "Required" appears immediately below both the "First Name" and "Last Name" input fields. |
| 3 | Enter a value in "First Name", leave "Last Name" blank, and click "Save". | Red "Required" warning remains visible under the "Last Name" field, but disappears under the "First Name" field. |

---

## TC-PIM-004: Verify Middle Name and Employee ID are Optional on Creation

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-004 |
| Test Condition | PC-005 |
| Module | PIM |
| Priority | Medium |
| Type | Validation |
| Preconditions | The user is on the "Add Employee" page. |
| Test Data | First Name: `TestFirst`; Last Name: `TestLast`; Middle Name: (Leave empty); Employee Id: (Clear default auto-generated ID) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Input `TestFirst` in First Name and `TestLast` in Last Name. | Inputs are accepted. |
| 2 | Clear the pre-populated value in the Employee Id field, leaving it completely blank. | Field is empty. |
| 3 | Click the "Save" button. | The employee profile should be created successfully without showing validation errors for Middle Name or Employee Id. (Note: System behavior is observed to automatically assign a sequential ID if left blank). |

---

## TC-PIM-005: Verify Successful Employee Creation with Default Auto-Generated ID

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-005 |
| Test Condition | PC-008 |
| Module | PIM |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the "Add Employee" page. |
| Test Data | First Name: `Jane`; Middle Name: `Marie`; Last Name: `Doe` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Verify that the "Employee Id" field contains an automatically populated 4-digit numeric string (e.g. `0488`). | The pre-populated Employee ID is visible. |
| 2 | Enter `Jane` in First Name, `Marie` in Middle Name, and `Doe` in Last Name. Keep the default Employee ID. | All values are inputted. |
| 3 | Click the "Save" button. | Employee creation succeeds. The user is redirected to the Personal Details page for the new employee (URL contains `/pim/viewPersonalDetails/empNumber/`). A green success toast notification "Successfully Saved" is displayed. |

---

## TC-PIM-006: Verify Manually Overriding Employee ID on Creation

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-006 |
| Test Condition | PC-009 |
| Module | PIM |
| Priority | Medium |
| Type | Functional |
| Preconditions | The user is on the "Add Employee" page. |
| Test Data | First Name: `John`; Last Name: `Smith`; Custom Employee ID: `9999` (unique custom ID) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Enter `John` in First Name and `Smith` in Last Name. | Inputs are accepted. |
| 2 | Focus the "Employee Id" field, clear the auto-generated number, and input `9999`. | The field displays `9999`. |
| 3 | Click the "Save" button. | Employee creation succeeds. The user is redirected to the Personal Details page and the custom Employee ID `9999` is saved correctly in the record. |

---

## TC-PIM-007: Verify Profile Photo Upload Formats and Sizes

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-007 |
| Test Condition | PC-010, PC-011 |
| Module | PIM |
| Priority | Medium |
| Type | Validation |
| Preconditions | The user is on the "Add Employee" page. |
| Test Data | Profile Photo A: `valid_image.png` (PNG format, size 500KB); Profile Photo B: `invalid_file.txt` (Text document) |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click the profile picture upload button, select `valid_image.png`, and upload. | The image file is accepted. The placeholder is replaced with a preview of the uploaded photo. |
| 2 | Click the profile picture upload button, select `invalid_file.txt`, and attempt to upload. | The file upload should fail. The system should reject the file format and display an error message (or maintain the previous photo preview without crashing). |

---

## TC-PIM-008: Verify Mandatory Fields and Password Warnings in Login Details Creation

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-008 |
| Test Condition | PC-006, PC-007 |
| Module | PIM |
| Priority | High |
| Type | Validation |
| Preconditions | The user is on the "Add Employee" page. |
| Test Data | First Name: `Login`; Last Name: `User`; Username: `loginuser`; Short Password: `abc` (under 8 characters); Mismatched Confirmation Password: `xyz` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Input First Name `Login` and Last Name `User`. | Inputs are accepted. |
| 2 | Click the "Create Login Details" toggle switch (switch label indicator turns green). | The Login Details form inputs expand (Username, Status, Password, Confirm Password are now visible). |
| 3 | Leave the Username, Password, and Confirm Password fields empty and click the "Save" button. | Submission fails. Red text "Required" is displayed below the Username, Password, and Confirm Password fields. |
| 4 | Fill the Username, enter `abc` in Password, enter `xyz` in Confirm Password, and click "Save". | Submission fails. Validation warnings are displayed (Password must contain at least 8 characters, and Confirm Password does not match Password). |

---

## TC-PIM-009: Verify Successful Employee Creation with Active Login Details

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-009 |
| Test Condition | PC-012 |
| Module | PIM |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the "Add Employee" page. |
| Test Data | First Name: `Secure`; Last Name: `Employee`; Username: `secureemployee1`; Password: `Valid Employee Password`; Confirm Password: `Valid Employee Password` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Fill in First Name `Secure` and Last Name `Employee`. | Inputs are accepted. |
| 2 | Click the "Create Login Details" toggle switch. | The login credentials configuration panel is revealed. |
| 3 | Input Username `secureemployee1`, select Status `Enabled`, enter `Valid Employee Password` in Password, and matching confirmation password. | Inputs are accepted and masking is active for password fields. |
| 4 | Click the "Save" button. | Employee profile and corresponding login credentials are created successfully. Redirection to Personal Details page occurs, and a green success banner is shown. |

---

## TC-PIM-010: Verify Employee Search by Exact Name and ID

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-010 |
| Test Condition | PC-013, PC-014 |
| Module | PIM |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the PIM Employee List page. At least one employee record (e.g. Name: `Jane Marie Doe`, ID: `0488`) exists in the database. |
| Test Data | Search Name: `Jane Marie Doe`; Search ID: `0488` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Focus the "Employee Name" input field, type `Jane Marie Doe`, and wait for auto-hints. | An autocomplete drop-down hint containing "Jane Marie Doe" is displayed. Select the name from the hints. |
| 2 | Click the "Search" button. | The table results grid reloads, displaying exactly the record matching `Jane Marie Doe` in the rows list. |
| 3 | Click the "Reset" button. Clear inputs. Focus "Employee Id" input, type `0488`, and click "Search". | The table results grid reloads, displaying exactly the single row matching ID `0488`. |

---

## TC-PIM-011: Verify Employee Search by Job Title and Employment Status

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-011 |
| Test Condition | PC-015 |
| Module | PIM |
| Priority | Medium |
| Type | Functional |
| Preconditions | The user is on the PIM Employee List page. |
| Test Data | Job Title dropdown selection; Employment Status dropdown selection |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Click the "Job Title" dropdown, select a specific title (e.g., "QA Engineer" or another title), and click "Search". | The results table reloads and displays only employee records matching the selected Job Title. |
| 2 | Click "Reset". Click the "Employment Status" dropdown, select a status (e.g. "Full-Time Permanent"), and click "Search". | The results table reloads and displays only records matching the selected Employment Status. |

---

## TC-PIM-012: Verify Reset Button Clears Search Filter Inputs

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-012 |
| Test Condition | PC-016 |
| Module | PIM |
| Priority | Medium |
| Type | Usability |
| Preconditions | The user is on the PIM Employee List page. |
| Test Data | Employee Name: `Jane`; Employee ID: `0488`; Job Title: "QA Engineer" |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Populate Employee Name with `Jane`, Employee Id with `0488`, and select a Job Title. | All inputs contain the selected values. |
| 2 | Click the "Reset" button. | All text input fields are cleared, dropdown selectors revert to their default states (e.g., "-- Select --" or "Current Employees Only"), and the table results reload to display the default listing. |

---

## TC-PIM-013: Verify Pagination on Employee List Table

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-013 |
| Test Condition | PC-017 |
| Module | PIM |
| Priority | Low |
| Type | Usability |
| Preconditions | The database contains more employee records than the default page display limit (e.g. 50+ records). |
| Test Data | None |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Scroll to the bottom of the PIM Employee List page and verify the presence of pagination controls. | A pagination widget showing page numbers (1, 2, next, last) is visible. |
| 2 | Click on the Page "2" button. | The table results update, loading the next set of employee records. The page number "2" indicator is styled as active. |

---

## TC-PIM-014: Verify Successful Deletion of a Selected Employee Record

| Field | Value |
|---|---|
| Test Case ID | TC-PIM-014 |
| Test Condition | PC-018 |
| Module | PIM |
| Priority | High |
| Type | Functional |
| Preconditions | The user is on the PIM Employee List page. A test employee record (ID: `9999`) exists in the table. |
| Test Data | Employee ID to delete: `9999` |

### Test Steps

| Step | Action | Expected Result |
|---|---|---|
| 1 | Input `9999` in the "Employee Id" search filter and click "Search" to filter the record. | The single row matching ID `9999` is displayed in the table. |
| 2 | Click the checkbox selector in the left-most column of the employee record row. | The checkbox is checked. The row background is highlighted. |
| 3 | Click the check box, verify that the table header action button (trash bin or "Delete Selected") becomes visible/clickable, and click it. | A confirmation dialog titled "Are you Sure?" is displayed. |
| 4 | Click the "Yes, Delete" button inside the modal dialog. | The dialog disappears, a green toast notification "Successfully Deleted" is displayed, and the results table reloads showing "No Records Found". |

---

## Test Condition Traceability

The following matrix maps the PIM Test Conditions to their corresponding test cases:

| Condition ID | Test Case IDs | Notes / Comments |
|---|---|---|
| **PC-001** | TC-PIM-001 | Covers PIM dashboard sub-menu tabs. |
| **PC-002** | TC-PIM-001 | Covers search card dropdown and text input visibility. |
| **PC-003** | TC-PIM-002 | Covers Add Employee form fields layout visibility. |
| **PC-004** | TC-PIM-003 | Covers blank mandatory field validation alerts. |
| **PC-005** | TC-PIM-004 | Covers optional state of Middle Name and Employee ID. |
| **PC-006** | TC-PIM-008 | Covers blank login credentials validations. |
| **PC-007** | TC-PIM-008 | Covers password mismatch and length warnings. |
| **PC-008** | TC-PIM-005 | Covers standard creation using auto-generated IDs. |
| **PC-009** | TC-PIM-006 | Covers manual overriding of the Employee ID. |
| **PC-010** | TC-PIM-007 | Covers successful profile photo attachment. |
| **PC-011** | TC-PIM-007 | Covers photo type constraints validation. |
| **PC-012** | TC-PIM-009 | Covers successful employee creation with active login account. |
| **PC-013** | TC-PIM-010 | Covers list filter query by employee name matching. |
| **PC-014** | TC-PIM-010 | Covers list filter query by Employee ID matching. |
| **PC-015** | TC-PIM-011 | Covers dropdown filter queries (Job Title, Status). |
| **PC-016** | TC-PIM-012 | Covers filter inputs restoration on Reset click. |
| **PC-017** | TC-PIM-013 | Covers table navigation widgets. |
| **PC-018** | TC-PIM-014 | Covers record selection delete workflows. |

---

## Test Case Summary

### Priority Distribution
* **High Priority**: 8 test cases
* **Medium Priority**: 5 test cases
* **Low Priority**: 1 test case
* **Total Test Cases**: `14`

### Test Type Distribution
* **UI**: 2 test cases
* **Validation**: 4 test cases
* **Functional**: 6 test cases
* **Usability**: 2 test cases
