# OrangeHRM Manual Testing Portfolio Project

## Project Overview
This repository is being developed as a professional manual QA portfolio project based on hands-on testing of the OrangeHRM Open Source Demo Application. The goal of this project is to showcase real-world manual testing methodologies, structured documentation, and defect tracking in a professional format.

> [!IMPORTANT]
> **Integrity and Accuracy Commitment:**
> - This project will reflect **actual manual testing activities** on the live OrangeHRM demo instance.
> - **No fabricated testing evidence** (such as fake test counts, pass percentages, or simulated bug reports) will be included.
> - Test execution results will be updated only after actual hands-on test execution.
> - Screenshots will be captured during live execution, representing authentic system behavior.
> - Bug reports will contain only reproducible observations logged during live testing sessions.
> - The repository will be expanded incrementally, module by module.

---

## Project Objectives
- Demonstrate industry-standard QA documentation, including Requirements Analysis, Test Plans, Test Cases, and Bug Reports.
- Apply black-box testing techniques (Equivalence Partitioning, Boundary Value Analysis, Decision Tables, State Transition) on a real-world web application.
- Establish a clear requirements-to-test-case traceability matrix as a future objective, after completing the actual requirements/module analysis and test-case design.
- Perform structured exploratory testing and regression testing.

---

## Planned Modules
The project is planned to cover the following four modules of the OrangeHRM system, with their specific functional areas to be verified:
1. **Login Module** *(Completed / Verified)*: User authentication, authorization, session management, and validation.
2. **PIM (Personnel Information Management) Module** *(Completed / Verified)*: Employee records management, adding/editing/searching employee data, and list views.
3. **Leave Module** *(Completed / Verified)*: Leave request creation, approval workflow, configurations, and balance tracking.
4. **Admin Module** *(Completed / Verified)*: System user management, job configurations, organization structures, and system configurations.

---

## Testing Approach

> [!NOTE]
> **Testing Delivery Method:**
> This repository is a **Manual QA Portfolio Project**. 
> - All test plans, requirements matrices, and test cases were designed and formatted manually from a black-box testing perspective.
> - All test cases were executed manually on the live web browser to verify application behaviors.
> - Screenshots were captured manually during live testing sessions to serve as visual execution evidence.

The project workflow follows a structured manual testing lifecycle:
1. **Actual application exploration**: Navigating the live system to understand real UI behavior and flows.
2. **Verified module analysis**: Documenting actual functional areas, business rules, and validation points.
3. **Test condition identification**: Outlining specific scenarios and conditions to be tested.
4. **Test case design**: Creating detailed manual test cases with preconditions, steps, inputs, and expected results.
5. **Test execution**: Executing tests manually on the target environment.
6. **Evidence collection**: Capturing real screenshots and documenting actual behavior.
7. **Defect reporting**: Logging clear, reproducible bugs for any failures.
8. **Retesting/regression**: Verifying defect fixes and performing regression tests where applicable.
9. **Test summary**: Compiling final execution results and summary metrics.

---

## Testing Evidence Approach
To maintain professional transparency:
- **Screenshots**: Screen captures will be saved in `test-execution/screenshots/` and linked directly in test cases or bug reports when deviations or failures occur.
- **Bug Reports**: Each reported bug will be documented in `bug-reports/` using a standardized template.
- **Traceability**: A requirements-to-test-case mapping will be established and maintained after actual requirements/module analysis and test-case design are complete.

---

## Repository Structure
```text
orangehrm-manual-testing/
│
├── README.md                           # Project overview, goals, and status
│
├── requirements/
│   └── module-analysis.md              # Requirements and functional analysis
│
├── test-plan/
│   └── orangehrm-test-plan.md          # Test strategy and scope per module
│
├── test-cases/
│   ├── login/                          # Test cases for the Login module (Completed)
│   ├── pim/                            # Test cases for the PIM module (Completed)
│   ├── leave/                          # Test cases for the Leave module (Completed)
│   └── admin/                          # Test cases for the Admin module (Completed)
│
├── test-execution/
│   └── screenshots/                    # Screenshots captured during actual execution (Completed)
│
├── bug-reports/                        # Standardized bug reports for failed cases (Template Added)
│
└── test-summary/                       # Final execution reports and summary metrics (Completed)
```

---

## Project Status
- **Current Status**: `Admin Module — Test Execution Completed`
- **Active Phase**: Master Project Closeout

### Login Module Status Dashboard
- **Login Module Analysis**: Completed
- **Login Test Cases**: Completed
- **Login Execution**: Completed (20 passed, 0 failed, 2 not executed)
- **Defects**: 0
- **Evidence**: 4 Screenshots captured (`TC-LOGIN-001`, `TC-LOGIN-003`, `TC-LOGIN-008`, `TC-LOGIN-009`)
- **Test Summary**: Completed

### PIM Module Status Dashboard
- **PIM Module Analysis**: Completed
- **PIM Test Cases**: Completed
- **PIM Execution**: Completed (15 passed, 0 failed, 0 not executed)
- **Defects**: 0
- **Evidence**: 6 Screenshots captured (`TC-PIM-001`, `TC-PIM-002`, `TC-PIM-005`, `TC-PIM-010`, `TC-PIM-014`, `TC-PIM-015`)
- **Test Summary**: Completed

### Leave Module Status Dashboard
- **Leave Module Analysis**: Completed
- **Leave Test Cases**: Completed
- **Leave Execution**: Completed (13 passed, 0 failed, 0 not executed)
- **Defects**: 0
- **Evidence**: 3 Screenshots captured (`TC-LEAVE-001`, `TC-LEAVE-002`, `TC-LEAVE-010`)
- **Test Summary**: Completed

### Admin Module Status Dashboard
- **Admin Module Analysis**: Completed
- **Admin Test Cases**: Completed
- **Admin Execution**: Completed (11 passed, 1 failed, 0 not executed)
- **Defects**: 1 (BUG-ADMIN-001 — Low severity)
- **Evidence**: 5 Screenshots captured (`TC-ADMIN-001`, `TC-ADMIN-002`, `TC-ADMIN-007`, `TC-ADMIN-010`, `BUG-ADMIN-001`)
- **Test Summary**: Completed

