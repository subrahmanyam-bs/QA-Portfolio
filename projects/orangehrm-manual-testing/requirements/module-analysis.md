# OrangeHRM Module Analysis Framework

This document captures the requirements, UI components, inputs, navigation, validation, and risks identified during exploratory analysis of the OrangeHRM demo application.

---

## Login Module Exploration

### 1. Environment Information
* **Application URL**: `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login` (Verified)
* **Date of exploration**: `2026-08-19` (Verified)
* **Browser**: `Google Chrome` (Verified)
* **Browser version**: `v133.0`
* **Operating system**: `Windows` (Verified)
* **Environment**: `Public Demo` (Verified)
* **Test account type**: `Admin` (Verified)

### 2. Login UI Analysis
*Only components observed during exploratory analysis are documented here.*

| UI Component | Observation | Verification Status |
| :--- | :--- | :--- |
| **Username field** | Input element (`name='username'`) with label text "Username" | `Verified` |
| **Password field** | Input element (`name='password'`) with label text "Password" | `Verified` |
| **Login button** | Submit button with label text "Login" | `Verified` |
| **Forgot Password link** | Text paragraph element with label text "Forgot your password?" | `Verified` |
| **Labels & Instructions** | "Username" and "Password" labels are displayed | `Verified` |
| **Icons & Branding Logos** | OrangeHRM logo and banner image elements are displayed | `Verified` |
| **Error message area** | Specific validation message fields and general error banners are present | `Verified` |
| **Password visibility control** | No eye icon or input visibility toggle element is present in the password container | `Verified` |

### 3. Input Behavior Analysis
*Actual input combinations and resulting observations recorded during active testing.*

| Scenario Observed | Input | Actual Observation | Verified |
| :--- | :--- | :--- | :--- |
| **Both fields empty** | Username: (empty); Password: (empty) | Fails to submit; displays validation message "Required" below both the Username and Password fields. URL remains the same. | `Verified` |
| **Username only** | Username: "Admin"; Password: (empty) | Fails to submit; displays validation message "Required" below the Password field only. URL remains the same. | `Verified` |
| **Password only** | Username: (empty); Password: Demo credential (not stored) | Fails to submit; displays validation message "Required" below the Username field only. URL remains the same. | `Verified` |
| **Invalid credentials** | Username: "InvalidUser"; Password: "wrongpass123" | Fails to login; displays alert banner with text "Invalid credentials" at the top of the form. URL remains the same. | `Verified` |
| **Valid credentials** | Username: Demo Admin account; Password: Demo credential (not stored) | Successfully logs in; redirects user to the dashboard page. | `Verified` |

### 4. Navigation Analysis
- **Login page URL**: `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login` (Verified)
- **Destination after successful login**: `https://opensource-demo.orangehrmlive.com/web/index.php/dashboard/index` with page title "OrangeHRM" and topbar header breadcrumb text "Dashboard" (Verified)
- **Logout behavior**: Clicking the user dropdown tab (`oxd-userdropdown-tab`) and selecting "Logout" redirects the user back to the login page (Verified)
- **Destination after logout**: `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login` with login input fields visible again (Verified)
- **Other navigation observed**: After logout, clicking the browser Back button resulted in the Login page being displayed at the login URL (`https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`). No Dashboard page was displayed during this observation. (Verified)

### 5. Validation Analysis
*Actual validations observed on input submission.*

| Input Condition | Action | Actual Message/Behavior | Location of Message | Observed During Exploration |
| :--- | :--- | :--- | :--- | :--- |
| Username and/or Password blank | Click "Login" | Displays text message "Required" | Span element `oxd-input-group__message` immediately below the corresponding input field | Yes — observed during exploration |
| Invalid credentials | Click "Login" | Displays alert banner with text "Invalid credentials" | Div element `oxd-alert-content` at the top of the login container | Yes — observed during exploration |

### 6. Authentication Behavior
- **Post-logout navigation behavior (external observation)**: After logout, clicking the browser Back button resulted in the Login page being displayed at the login URL. No Dashboard page was displayed during this observation. (Verified)
- **Lockout behavior (external observation)**: No account lockout or login restriction was observed after five consecutive failed login attempts on the public demo environment. The user was able to log in successfully and immediately with valid credentials on the sixth attempt. (Verified)
- **Remember me/session retention**: The active session persists across page refreshes. Additionally, the user session is synchronized across browser tabs; logging out in one tab invalidates the session in other tabs, redirecting the user back to the login screen upon their next interaction. (Verified)

### 7. Risks and Open Questions

#### Observed Risks
*No risks observed yet (awaiting active exploration).*

#### Testing Risks
- **Shared/Public Environment**: The shared/public demo environment may be modified or reset independently of this testing activity, which may affect test reproducibility.
- **Environment Availability**: The public demo environment may experience downtime, slow responses, or unexpected resets that could interrupt testing.

#### Open Questions
- What is the default lockout threshold for failed login attempts?
- Are there session timeout limitations on active or inactive sessions?
- What are the formatting and character limitations for credentials?

### 8. Analysis Status
- **Status**: `Completed`

---

## Login Module Test Conditions

The following matrix identifies the test conditions defined for the Login module to ensure systematic, risk-based coverage prior to detailed test-case design.

| Condition ID | Area | Test Condition | Basis | Status | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **LC-001** | UI / Basic Controls | Verify presence and basic visibility of the identified Login UI elements. | Exploratory observation | Observed | High |
| **LC-002** | UI / Basic Controls | Verify character masking on the Password field during entry. | Planned coverage | Planned / Not Verified | High |
| **LC-003** | UI / Basic Controls | Verify whether a password visibility control is available for the Password field. | Exploratory observation | Observed | Medium |
| **LC-004** | Input Validation | Verify validation message when submitting with both Username and Password fields empty. | Exploratory observation | Observed | High |
| **LC-005** | Input Validation | Verify validation message when submitting with Username populated and Password empty. | Exploratory observation | Observed | High |
| **LC-006** | Input Validation | Verify validation message when submitting with Username empty and Password populated. | Exploratory observation | Observed | High |
| **LC-007** | Input Validation | Verify validation behavior for inputs with leading and trailing whitespaces. | Planned coverage | Planned / Not Verified | Medium |
| **LC-008** | Input Validation | Verify input behavior when Username and Password fields contain special characters. | Planned coverage | Planned / Not Verified | Medium |
| **LC-009** | Input Validation | Verify validation and error handling for extremely long inputs (boundary-length testing). | Planned coverage | Planned / Not Verified | Medium |
| **LC-010** | Input Validation | Verify ability to copy/paste credentials into Username and Password fields. | Planned coverage | Planned / Not Verified | Medium |
| **LC-011** | Authentication | Verify successful authentication with valid Demo Admin credentials. | Exploratory observation | Observed | High |
| **LC-012** | Authentication | Verify failure of authentication with invalid username and invalid password. | Exploratory observation | Observed | High |
| **LC-013** | Authentication | Verify failure of authentication with valid username and invalid password. | Planned coverage | Planned / Not Verified | High |
| **LC-014** | Authentication | Verify failure of authentication with invalid username and valid password. | Planned coverage | Planned / Not Verified | High |
| **LC-015** | Authentication | Verify credential case-sensitivity behavior (e.g. valid username with different case). | Planned coverage | Planned / Not Verified | Medium |
| **LC-016** | Authentication | Verify whether repeated failed login attempts trigger any observable account lockout or authentication restriction. | Planned coverage | Planned / Not Verified | High |
| **LC-017** | Navigation | Verify successful redirection to Dashboard URL on successful login. | Exploratory observation | Observed | High |
| **LC-018** | Navigation | Verify user is kept on Login page URL on failed login. | Exploratory observation | Observed | High |
| **LC-019** | Navigation | Verify redirect to Login page and form visibility after explicit logout action. | Exploratory observation | Observed | High |
| **LC-020** | Navigation | Verify browser Back button behavior after logout. | Exploratory observation | Observed | High |
| **LC-021** | Navigation | Verify redirect to Reset Password page on clicking the "Forgot your password?" link. | Planned coverage | Planned / Not Verified | Medium |
| **LC-022** | Session Behavior | Verify that direct navigation to Dashboard page URL without active session redirects to Login page. | Planned coverage | Planned / Not Verified | High |
| **LC-023** | Session Behavior | Verify session persistence across page refreshes. | Planned coverage | Planned / Not Verified | Medium |
| **LC-024** | Session Behavior | Verify active session behavior when opening dashboard in a new tab or window. | Planned coverage | Planned / Not Verified | Medium |
| **LC-025** | Session Behavior | Verify automatic session expiration after a designated period of inactivity (idle timeout). | Planned coverage | Planned / Not Verified | Medium |
| **LC-026** | Usability / Compatibility | Verify keyboard navigation using the Tab key to traverse focus sequentially through input fields and Login button. | Planned coverage | Planned / Not Verified | Medium |
| **LC-027** | Usability / Compatibility | Verify that pressing the Enter key inside either input field triggers the form submit action. | Planned coverage | Planned / Not Verified | Medium |
| **LC-028** | Usability / Compatibility | Verify Login layout rendering and UI responsiveness on standard supported screen resolutions. | Planned coverage | Planned / Not Verified | Low |
| **LC-029** | Usability / Compatibility | Verify Login function and visual layout rendering across different supported browsers (e.g., Firefox, Safari, Edge). | Planned coverage | Planned / Not Verified | Low |

---

## PIM (Personnel Information Management) - Module Analysis

This section captures the functional components, user flows, business logic, validation rules, and risks identified during exploratory analysis of the Personnel Information Management (PIM) module.

### 1. Functional Areas
- **Employee List Page**: Main search dashboard used to query employee records using specific filters and view list grids.
- **Add Employee Page**: Multi-input creation form used to register new employee profiles.
- **Optional/Custom Configurations**: Configuration sub-menus to adjust fields, custom fields, data import, reporting methods, and termination reasons.
- **Reports Dashboard**: Sub-module used to define and generate custom employee profile reports.

### 2. User Flows
- **Create Employee Profile**: Input names and ID, select profile image, and save.
- **Create Employee Profile with Login Credentials**: Input names, toggle the credentials switch, input credentials (username, password, matching confirmations), and save.
- **Search Employee Records**: Input filter criteria on the search card, click "Search", and verify the results grid.
- **Delete Employee Record**: Locate an employee, click the checkbox, click "Delete Selected" in the table header, and confirm.

### 3. Business Rules
- **Mandatory Inputs**: `First Name` and `Last Name` are required fields. `Middle Name` is optional.
- **Employee ID Auto-Generation**: The system automatically generates a unique 4-digit Employee ID (e.g. `0488`) on page load. The ID can be manually overridden.
- **Profile Photo Input**: File selector accepts image formats (Type: `file`). Boundary resolution/size limits are unverified.
- **Login Credentials Toggle**: Activating the switch reveals three credentials fields (Username, Password, Confirm Password) and a Status radio toggle (Enabled/Disabled).

### 4. Validation Points
- Leaving `First Name` or `Last Name` empty triggers a red `"Required"` inline validation message under the respective field.
- Password complexity or short username entries during credential creation trigger validation errors in red text.

### 5. Risks and Open Questions
- **Shared Test Data**: Other public users can modify or delete created employee records, making specific searches fail if records are removed.
- **Auto-generated ID collision**: Overriding the auto-generated ID manually with an existing ID could trigger a primary key collision error.

---

## PIM Module Test Conditions

The following matrix outlines the test conditions defined for the PIM module to guide manual test-case design:

| Condition ID | Area | Test Condition | Basis | Status | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PC-001** | UI / Basic Controls | Verify presence and basic visibility of all PIM sub-navigation tabs (Configuration, Employee List, Add Employee, Reports). | Exploratory observation | Observed | High |
| **PC-002** | UI / Basic Controls | Verify presence and basic visibility of PIM Search Filter Fields. | Exploratory observation | Observed | Medium |
| **PC-003** | UI / Basic Controls | Verify presence and basic visibility of PIM Add Employee Form Inputs. | Exploratory observation | Observed | High |
| **PC-004** | Input Validation | Verify validation message when submitting the Add Employee form with blank First Name and Last Name. | Planned coverage | Planned / Not Verified | High |
| **PC-005** | Input Validation | Verify that Middle Name and Employee ID are optional during employee creation. | Planned coverage | Planned / Not Verified | Medium |
| **PC-006** | Input Validation | Verify validation warnings on Login Details inputs when "Create Login Details" is toggled and fields are left empty. | Planned coverage | Planned / Not Verified | High |
| **PC-007** | Input Validation | Verify validation warnings on Password matching during Login Details creation. | Planned coverage | Planned / Not Verified | High |
| **PC-008** | Employee Creation | Verify successful employee creation with default auto-generated Employee ID. | Planned coverage | Planned / Not Verified | High |
| **PC-009** | Employee Creation | Verify that a manually overridden Employee ID is saved correctly. | Planned coverage | Planned / Not Verified | Medium |
| **PC-010** | Employee Creation | Verify profile photo upload with valid image format and size. | Planned coverage | Planned / Not Verified | Medium |
| **PC-011** | Employee Creation | Verify profile photo upload rejection on invalid file type or boundary size. | Planned coverage | Planned / Not Verified | Medium |
| **PC-012** | Employee Creation | Verify successful employee creation with active Login Details credentials. | Planned coverage | Planned / Not Verified | High |
| **PC-013** | Search & Filtering | Verify search results on Employee List by exact Employee Name. | Planned coverage | Planned / Not Verified | High |
| **PC-014** | Search & Filtering | Verify search results on Employee List by exact Employee ID. | Planned coverage | Planned / Not Verified | High |
| **PC-015** | Search & Filtering | Verify search results on Employee List by drop-down selection (Job Title, Employment Status). | Planned coverage | Planned / Not Verified | Medium |
| **PC-016** | Search & Filtering | Verify Reset button clears search filters and restores defaults on the Employee List. | Planned coverage | Planned / Not Verified | Medium |
| **PC-017** | Search & Filtering | Verify pagination control and navigation on PIM Employee List table when multiple records exist. | Planned coverage | Planned / Not Verified | Low |
| **PC-018** | Record Deletion | Verify successful deletion of a selected employee from the Employee List table. | Planned coverage | Planned / Not Verified | High |

---

## Leave - Module Analysis

This section captures the functional components, user flows, business logic, validation rules, and risks identified during exploratory analysis of the Leave Module.

### 1. Functional Areas
- **Leave List Dashboard**: Used to search and filter through employee leave history (From/To dates, status filters, Leave Type, Employee Name).
- **Assign Leave Page**: Administrative panel to allocate leave manually to a selected employee.
- **My Leave List**: Personal dashboard for employees to view their active leave status.
- **Leave Entitlements**: Section to add or configure leave balances per employee or group.

### 2. User Flows
- **Assigning Leave**: Enter Employee Name, select Leave Type, input date range (From Date, To Date), check Leave Balance (read-only), add Comments, and click Assign.
- **Filtering Leave List**: Select date range, select status checkboxes (Rejected, Cancelled, Pending Approval, Scheduled, Taken), select Leave Type, input Employee Name, and click Search.

### 3. Business Rules
- **Employee Name Validation**: Must match a valid, existing employee record. Leaving it empty or typing a non-existent name triggers validation errors.
- **Leave Type Selector**: Mandatory select dropdown.
- **Date Format and Ordering**: The date format is strictly `yyyy-dd-mm` (Year-Day-Month). `From Date` must be less than or equal to `To Date`.
- **Date Inversion Validation**: Selecting a `From Date` that is after the `To Date` triggers a red validation message `"To date should be after from date"` (or similar).
- **Leave Balance Check**: A read-only balance label dynamically updates upon selecting an employee and Leave Type.

### 4. Validation Points
- **Inverted Dates Validation**: Selecting `From Date` later than `To Date` triggers a red warning: `"To date should be after from date"`.
- **Invalid Date Format Validation**: Entering strings not matching `yyyy-dd-mm` triggers a red warning: `"Should be a valid date in yyyy-dd-mm format"`.
- **Blank Required Inputs**: Submitting Assign Leave with blank mandatory fields triggers a red `"Required"` inline warning under each empty field.

### 5. Risks and Open Questions
- **Leave Overlap Policy**: System constraints on assigning leave on date ranges that overlap with existing records must be validated to ensure overlapping assignments are blocked.

---

## Leave Module Test Conditions

The following matrix outlines the test conditions defined for the Leave module to guide manual test-case design:

| Condition ID | Area | Test Condition | Basis | Status | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **LC-LV-001** | UI / Basic Controls | Verify presence and basic visibility of all Leave sub-navigation tabs (Apply, My Leave, Entitlements, Reports, Configure, Leave List, Assign Leave). | Exploratory observation | Observed | High |
| **LC-LV-002** | UI / Basic Controls | Verify presence and visibility of Assign Leave form input fields and dropdowns. | Exploratory observation | Observed | High |
| **LC-LV-003** | UI / Basic Controls | Verify presence and visibility of Leave List search filter card inputs. | Exploratory observation | Observed | Medium |
| **LC-LV-004** | Input Validation | Verify validation warnings on Assign Leave form when submitting with blank mandatory fields. | Planned coverage | Planned / Not Verified | High |
| **LC-LV-005** | Input Validation | Verify Employee Name auto-hints and validation error when entering an invalid/non-existent employee name. | Planned coverage | Planned / Not Verified | High |
| **LC-LV-006** | Input Validation | Verify validation error warning when To Date is earlier than From Date (date inversion check). | Planned coverage | Planned / Not Verified | High |
| **LC-LV-007** | Input Validation | Verify validation error warning when entering an invalid date format (non `yyyy-dd-mm`). | Planned coverage | Planned / Not Verified | Medium |
| **LC-LV-008** | Leave Assignment | Verify read-only state of the "Leave Balance" indicator panel on Assign Leave form. | Planned coverage | Planned / Not Verified | Medium |
| **LC-LV-009** | Leave Assignment | Verify default placeholder format `yyyy-dd-mm` inside From Date and To Date input fields. | Planned coverage | Planned / Not Verified | Medium |
| **LC-LV-010** | Leave Assignment | Verify calendar date-picker modal popup opens successfully when clicking the calendar icon. | Planned coverage | Planned / Not Verified | Low |
| **LC-LV-011** | Leave Assignment | Verify successful leave assignment when all mandatory inputs are valid. | Planned coverage | Planned / Not Verified | High |
| **LC-LV-012** | Search & Filtering | Verify search results on Leave List card when filtering by Employee Name. | Planned coverage | Planned / Not Verified | High |
| **LC-LV-013** | Search & Filtering | Verify search results on Leave List card when filtering by exact Leave Type. | Planned coverage | Planned / Not Verified | Medium |
| **LC-LV-014** | Search & Filtering | Verify Reset button clears search inputs and restores defaults on the Leave List. | Planned coverage | Planned / Not Verified | Medium |
| **LC-LV-015** | Record Deletion | Verify that assigning overlapping leave dates for the same employee triggers an overlay warning or validation block. | Planned coverage | Planned / Not Verified | High |

---

## Admin - Module Analysis

This section captures the functional components, user flows, business logic, validation rules, and risks identified during exploratory analysis of the Admin Module.

### 1. Functional Areas
- **System Users Dashboard**: Used to search and filter system user accounts (by Username, User Role, Employee Name, and Status) and delete records from the grid.
- **Add User Page**: Panel form to register new system credentials and assign them to an employee profile.
- **Organization & Configurations**: Configuration sections for structural job settings, qualifications, nationalities, corporate branding, and email configuration.

### 2. User Flows
- **Add System User**: Select User Role (Admin/ESS), autocomplete select Employee Name, select Status (Enabled/Disabled), input unique Username, enter Password, confirm password, and click Save.
- **Filter System Users**: Input username, dropdown select user role and status, autocomplete select employee name, and click Search.

### 3. Business Rules
- **Mandatory Fields**: All inputs on the user registration form (User Role, Employee Name, Status, Username, Password, Confirm Password) are mandatory.
- **Employee Name Selection**: Autocomplete search that requires matching an existing employee profile in the system database.
- **Username Uniqueness**: Usernames must be unique in the system database. Duplicate names are rejected.
- **Password Strength**: Minimum 8-character length limit. Mismatched confirmation strings are rejected.

### 4. Validation Points
- **Blank Required Inputs**: Clicking Save with empty inputs triggers a red `"Required"` inline warning below each empty field.
- **Invalid Employee Lookup**: Entering an invalid or non-matching name in Employee Name triggers `"Invalid"` autocomplete warning.
- **Password Warnings**: Passwords under 8 characters or confirmation mismatch strings trigger red validation warnings under the password inputs.

### 5. Risks and Open Questions
- **Username Collision**: Registering a username that already exists in the system will fail with an error. Test runs must generate unique timestamped usernames to prevent collisions.

---

## Admin Module Test Conditions

The following matrix outlines the test conditions defined for the Admin module to guide manual test-case design:

| Condition ID | Area | Test Condition | Basis | Status | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **LC-AD-001** | UI / Basic Controls | Verify presence and basic visibility of all Admin sub-navigation menu headers (User Management, Job, Organization, Qualifications, Nationalities, Corporate Branding, Configuration). | Exploratory observation | Observed | High |
| **LC-AD-002** | UI / Basic Controls | Verify presence and visibility of Add User form input fields and dropdowns. | Exploratory observation | Observed | High |
| **LC-AD-003** | UI / Basic Controls | Verify presence and visibility of System Users search filter card inputs. | Exploratory observation | Observed | Medium |
| **LC-AD-004** | Input Validation | Verify validation warnings on Add User form when submitting with blank mandatory fields. | Planned coverage | Planned / Not Verified | High |
| **LC-AD-005** | Input Validation | Verify Employee Name auto-hints and validation error when entering an invalid/non-existent employee name. | Planned coverage | Planned / Not Verified | High |
| **LC-AD-006** | Input Validation | Verify validation warnings on Password length and confirmation mismatch. | Planned coverage | Planned / Not Verified | High |
| **LC-AD-007** | User Creation | Verify successful user creation when all mandatory details are valid. | Planned coverage | Planned / Not Verified | High |
| **LC-AD-008** | Search & Filtering | Verify search results on System Users list filtering by exact Username. | Planned coverage | Planned / Not Verified | High |
| **LC-AD-009** | Search & Filtering | Verify search results on System Users list filtering by User Role and Status dropdowns. | Planned coverage | Planned / Not Verified | Medium |
| **LC-AD-010** | Search & Filtering | Verify Reset button clears search card filter inputs and restores defaults. | Planned coverage | Planned / Not Verified | Medium |
| **LC-AD-011** | Record Deletion | Verify successful deletion of selected system user record from the database list grid. | Planned coverage | Planned / Not Verified | High |
| **LC-AD-012** | Input Validation | Verify that entering a duplicate/already-registered Username triggers a validation warning block. | Planned coverage | Planned / Not Verified | High |

