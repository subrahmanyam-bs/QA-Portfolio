# Medusa E-Commerce Platform - Test Plan

**Document version:** 1.0
**Application under test:** Medusa v2.19.0 (local instance) + public Next.js Starter demo (`next.medusajs.com`) for UI observation
**Status:** Active

---

## 1. Introduction
This plan defines the scope, approach, and deliverables for QA testing of Medusa, an open-source headless commerce platform, covering its Store API, Admin API, and underlying PostgreSQL database. Full environment details are in [`requirements/module-analysis.md`](../requirements/module-analysis.md).

## 2. Project Objective
Demonstrate structured, evidence-based QA practice across manual functional testing, API testing, and database testing of a real, multi-module e-commerce backend: authentication, catalog, cart, checkout, orders, customers, regions/currency. Honest reporting on what was and wasn't actually run is part of the point, not an afterthought.

## 3. Scope

### In scope
- **Authentication**: admin login, customer registration/login, invalid credentials, missing/malformed auth, authorization enforcement on protected routes.
- **Products**: listing, detail retrieval, variants, region-scoped pricing, invalid product IDs.
- **Carts**: creation, add/update/remove line items, quantity validation (including boundary and decimal values), cart-to-checkout data (address, shipping method, payment session), invalid/nonexistent cart handling.
- **Customers**: registration, duplicate-email handling, profile retrieval, unauthenticated access enforcement.
- **Regions**: listing, country-to-region mapping, region-scoped pricing behavior.
- **Orders**: cart-to-order completion, order retrieval, order field consistency (status/payment_status/fulfillment_status), unauthorized order access.
- **API testing**: Store API and Admin API. Positive, negative, validation, and status-code/schema checks, documented in `api-testing/` with a runnable Postman collection.
- **Database testing**: schema-level and referential-integrity checks against the real local PostgreSQL instance (`database-testing/`).
- **UI observation**: read-only exploratory review of the public Medusa Next.js Starter demo storefront, and the local Admin dashboard's static reachability.

### Out of scope
- Interactive/visual browser testing (click-through UI, screenshots of rendered pages). No browser tool available in this environment; see `requirements/module-analysis.md` Section 9.
- Real payment gateway integration (Stripe, PayPal, etc.). Only Medusa's manual/system-default provider is configured locally.
- Load, performance, and stress testing.
- Penetration testing / exploit development. Security-related checks are limited to authorized, non-destructive functional verification (authorization enforcement, input validation, error-message information disclosure).
- Multi-region/multi-currency comparison testing beyond the single seeded region ("Europe", EUR).
- Automation framework. Went manual + API-first for this round; check `README.md` for whether that changed later.

## 4. Test Environment
See [`requirements/module-analysis.md`](../requirements/module-analysis.md) for the full, verified environment matrix (URLs, versions, database, test accounts). In summary: Medusa v2.19.0 backend running locally on `http://localhost:9000`, PostgreSQL 17.11 on an isolated local instance, Node.js v24.12.0, Windows 11.

## 5. Modules in Scope
Authentication · Products · Carts · Customers · Regions · Orders · Store API · Admin API · Database

## 6. Testing Types
| Type | Applied to |
|---|---|
| Functional | All modules, via API-level black-box testing |
| Positive testing | Valid-input flows for every module (login, add-to-cart, checkout, etc.) |
| Negative testing | Invalid credentials, missing fields, invalid IDs, unauthorized access |
| Boundary testing | Cart quantity limits (0, negative, decimal, very large), field-length/format edges where discoverable via the API |
| Edge-case testing | Duplicate registration, guest vs. registered customer with the same email, repeated cart completion |
| API testing | Request/response schema, status codes, auth enforcement, error message correctness |
| Database testing | Referential integrity between `order`, `order_cart`, `cart`, `customer`; schema inspection |
| Exploratory testing | Initial, undocumented-path exploration to build `requirements/module-analysis.md` |
| Smoke testing | Health check, auth, product listing, cart creation, order completion: the minimum path that proves the environment is actually usable |
| Regression testing | Re-run of the smoke set after any environment change (documented in `test-execution/`) |
| End-to-end testing | Full guest checkout: cart creation → line item → address → shipping → payment session → order |

## 7. Test Approach
1. Explore the live, local Medusa instance directly (no assumptions from documentation alone) to confirm real request/response behavior.
2. Design test cases per module with explicit preconditions, test data, steps, and expected results, separating design (`test-cases/`) from execution results (recorded in the same files' Status column, with a consolidated `test-summary/`).
3. Execute a prioritized subset directly against the live API using `curl`, recording actual HTTP status codes and response bodies as evidence.
4. Cross-check API-observed outcomes against direct SQL queries on the underlying database where relevant.
5. Log any reproduced defect as a formal bug report with steps to reproduce and evidence.

## 8. Entry Criteria
- Local Medusa backend is installed, migrated, seeded, and reachable (`GET /health` returns `200`). — **Met.**
- At least one admin account and one customer account exist. — **Met.**
- A publishable API key is available for Store API calls. — **Met.**
- Module analysis and test case design are complete for a module before its test cases are executed.

## 9. Exit Criteria
- All test cases in `test-cases/` have a final status of `Pass`, `Fail`, `Blocked`, or `Not Executed` (no case left undecided).
- Every `Fail` has either a linked bug report or a documented reason it is not a defect.
- `test-summary/test-summary-report.md` reflects only actually-executed counts.
- No secrets (passwords, tokens, API keys) are present in any committed file.

## 10. Test Data
- Seeded defaults: 4 products (Medusa Shorts/T-Shirt/Sweatpants/Sweatshirt) with size variants, 1 region ("Europe", EUR, 7 countries), 2 shipping options.
- Project-created: 1 admin account, 1 registered customer account, ad-hoc guest checkout emails using the `+tag@example.com` convention to keep test data identifiable and non-colliding.
- No production or personally identifiable data is used anywhere.

## 11. Risks
| Risk | Mitigation |
|---|---|
| Local-only environment means results are not cross-verifiable against a shared/public instance | Every result is captured with the literal request/response as evidence in test cases and bug reports |
| No browser automation available, so UI test cases can't be visually confirmed | Marked `Blocked` with the reason stated, not assumed `Pass` and not quietly dropped |
| Native dependency installation (esbuild, @swc/core) was unreliable when run concurrently on this Windows machine (postinstall crashes) | Resolved by installing with `--ignore-scripts` and rebuilding each native package serially; documented here for transparency, not a product defect |
| Single seeded region limits multi-currency/region test depth | Explicitly scoped out rather than fabricated |

## 12. Assumptions
- The local instance's behavior is representative of standard Medusa v2.19.0 behavior (no custom modules or overrides were added beyond the default `create-medusa-app` scaffold).
- Test data created during this project (customers, carts, orders) may remain in the local database; no cleanup script was required since the database is not shared.

## 13. Dependencies
- PostgreSQL availability for the backend to start.
- Network access to `next.medusajs.com` for storefront UI observation.
- Node.js/npm toolchain for running and, where used, automating tests.

## 14. Deliverables
`requirements/module-analysis.md` · `test-plan/medusa-test-plan.md` · `test-cases/*` · `api-testing/api-test-cases.md` + Postman collection · `database-testing/database-test-cases.md` · `test-execution/` · `bug-reports/*` · `test-summary/test-summary-report.md` · `README.md`

## 15. Defect Management
Defects are logged only when actually reproduced (see `bug-reports/`), using the fields: Bug ID, Title, Module, Environment, Preconditions, Steps to Reproduce, Actual Result, Expected Result, Severity, Priority, Reproducibility, Evidence, Status. Severity/priority follow standard definitions (Critical/High/Medium/Low). No defect is fabricated to inflate the portfolio; where no defect was found for a tested area, that is stated plainly in the relevant test case and in the test summary.

## 16. Test Execution Approach
Execution is API-first. Each test case's steps are literal HTTP requests (method, path, headers, body) run against the live local backend, with the actual response recorded. For business-logic correctness that's just as valid as UI-driven black-box testing, it just doesn't stand in for actually looking at the UI, which is why those cases are marked `Blocked` instead of quietly assumed fine.

## 17. Regression Strategy
A minimal smoke set (health check, admin login, customer login, product listing, cart creation, full checkout) is defined in `test-execution/` and is intended to be re-run after any environment or seed-data change to confirm the baseline still holds.

## 18. Constraints
- No browser automation tool in this environment (see Section 11).
- No real payment gateway configured.
- Single-machine, local-only environment. Not wired into a CI pipeline.

## 19. Sign-off Criteria
Calling this plan done for portfolio purposes once: every module in scope has documented test cases, the prioritized smoke/negative subset is executed with evidence on record, every reproduced defect is logged, and the test summary's numbers actually match what was run, nothing padded.
