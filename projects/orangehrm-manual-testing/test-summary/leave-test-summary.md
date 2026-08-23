# OrangeHRM Leave Module Test Summary Report

This summary report aggregates the execution metrics, observations, and conclusions derived from testing the OrangeHRM Leave Module.

---

## 1. Executive Summary
Testing was conducted on the Leave Module of the OrangeHRM public demo application to verify that the leave list filters, administrative assign leave workflows, date range constraints, calendar picker popups, and formatting validation rules conform to manual testing guidelines.

The execution resulted in a **100% pass rate** (13 out of 13 test cases passed). The application successfully identifies required empty fields, triggers warnings for inverted date bounds, rejects non-matching employee names, and handles date overlap collisions. No defects were logged during this cycle.

---

## 2. Scope
- **Target Module**: Leave Module only.
- **In-Scope**: Sub-navigation menu layout tabs, search filter presence, Assign Leave card layout, blank required fields validations, autocomplete Employee Name lookups (valid vs. invalid), date range inversion validation, non-compliant date formats rejection, read-only leave balance display check, calendar date-picker modal popup, successful leave assignment, Employee Name matching search filter, dropdown leave type filtering, reset button functionality, and date overlap assignment restrictions.
- **Out-of-Scope**: My Leave list configurations inside non-admin views, detailed adjustments of holidays schedule configurations, leave period edits, and entitlements allocation backend calculations.

---

## 3. Environment
Testing was executed on Chromium (v133.0) on Windows 11. The application was hosted on the public demo instance: `https://opensource-demo.orangehrmlive.com/web/index.php/auth/login`.

---

## 4. Execution Statistics

| Metric | Count | Percentage |
| :--- | :---: | :---: |
| **Total Test Cases** | 13 | 100.0% |
| **Passed** | 13 | 100.0% |
| **Failed** | 0 | 0.0% |
| **Blocked** | 0 | 0.0% |
| **Not Executed** | 0 | 0.0% |
| **Overall Pass Rate** | — | **100.0%** |

---

## 5. Passed Tests
Thirteen test cases were executed and passed successfully. Key verifications include:
- Visual visibility check of Leave navigation menu tabs and filters (TC-LEAVE-001).
- Assign Leave form inputs and date placeholder checking (TC-LEAVE-002).
- Validation warning alerts displayed on empty mandatory inputs (TC-LEAVE-003).
- Invalid lookup names rejection in employee name autocomplete field (TC-LEAVE-004).
- Warning alerts on date ranges where To Date is earlier than From Date (TC-LEAVE-005).
- Rejection of slash date formats and string formatting errors (TC-LEAVE-006).
- Verification that Leave Balance informational panel is read-only (TC-LEAVE-007).
- Date-picker modal popup grid opening successfully on calendar icon click (TC-LEAVE-008).
- Successful leave assignment submission for a valid employee record (TC-LEAVE-009).
- Leave List history grid filtering matching exact Employee Name (TC-LEAVE-010).
- List filtering matching dropdown select (TC-LEAVE-011).
- Reset button clearing inputs back to blank strings (TC-LEAVE-012).
- Enforcing date range overlap validation boundaries on same employee (TC-LEAVE-013).

---

## 6. Defect Summary
* **Total Defects Logged**: `0`
* **Defect breakdown**: No deviations or bugs were logged during this testing cycle.

---

## 7. Risks & Limitations
- **Date Format Placeholder Inconsistency**: The application displays the format placeholder as `yyyy-dd-mm` (Year-Day-Month) inside the From/To Date input fields. However, the system's actual date-parsing engine expects `yyyy-mm-dd` (Year-Month-Day) when evaluating typed inputs. Typing `2026-15-08` (August 15, 2026) triggers format errors, whereas selecting dates via the visual datepicker avoids this. This is a critical usability risk.
- **Zero Entitlements Apply Block**: The standard "Apply Leave" page displays a `"No Leave Types with Leave Balance"` message for mock profiles, hiding all date and comments inputs. Administrative leave allocation must be tested via the "Assign Leave" page.

---

## 8. Key Observations
* **Date Picker Visual Alignment**: Utilizing the date picker modal automatically inputs dates in the format matching system rules, preventing format errors.
* **Overlapping Restriction**: Re-assigning leave to the same employee on a date range that is already scheduled triggers warning validation blocks.
* **Read-only Balance State**: The Leave Balance display panel is strictly informational and prevents manual edits.

---

## 9. Final Testing Conclusion
Based on the executed scope of 13 test cases, the OrangeHRM Leave Module operates correctly. Mandatory validation rules, datepicker interactions, reset buttons, and employee autocomplete fields match functional expectations. Resolving the interface date format placeholder typo is highly recommended to improve user clarity.
