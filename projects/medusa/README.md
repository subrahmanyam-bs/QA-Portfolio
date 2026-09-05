# Medusa QA Portfolio Project

## Project Overview

[Medusa](https://medusajs.com) is an open-source, headless commerce platform: a Node.js/TypeScript backend on PostgreSQL, exposing a **Store API** (catalog, cart, checkout, customer accounts) and an **Admin API** (orders, catalog, settings), plus a bundled Admin dashboard.

I picked it because it isn't a single-page demo site with one form to poke at. It's got real multi-module business logic: a product catalog, region/currency-scoped pricing, a stateful cart, a multi-step checkout, order lifecycle tracking. That's enough surface area to actually show manual, API, and database testing working together on one real e-commerce workflow, instead of three disconnected exercises.

Unlike some of the other apps in this portfolio, there's no public Medusa sandbox to test against. So I stood up a local instance specifically for this project, which meant the API and database testing here are genuinely executed results, not documentation-only guesswork. The full investigation and setup story is in [`requirements/module-analysis.md`](requirements/module-analysis.md).

## Testing Objectives

What this project is meant to show:
- Requirements/module analysis built from actually poking at the app, not just reading its docs.
- Test planning and test-case design kept separate from execution and results.
- Positive, negative, boundary, and edge-case coverage, not just the happy path.
- Real API testing, backed by a runnable Postman collection.
- Real database validation against the live schema.
- Honest defect reporting. Every bug here was actually reproduced, with request/response evidence attached.
- Honest scoping. What couldn't be tested (browser UI) is marked `Blocked`, not quietly dropped or faked.

## Scope

**Modules tested:** Authentication (admin + customer) · Products · Carts · Customers · Regions/Currency · Orders
**Interfaces tested:** Medusa Store API, Medusa Admin API, PostgreSQL database (read-only validation)
**Out of scope:** interactive browser UI testing (no browser tool in this environment), real payment gateways, load/performance testing, penetration testing. Full detail in [`test-plan/medusa-test-plan.md`](test-plan/medusa-test-plan.md).

## Testing Types

| Type | Status |
|---|---|
| Functional | Executed |
| API testing | Executed |
| Database testing | Executed |
| Negative testing | Executed |
| Boundary testing | Executed |
| Edge-case testing | Executed |
| Smoke testing | Executed |
| End-to-end testing (cart → order) | Executed |
| Exploratory testing | Executed (used to build the module analysis) |
| Regression testing | Partial. A minimal smoke set exists for re-running after environment changes, but it hasn't been run across multiple app versions |
| UI / Visual testing | **Not executed.** No browser tool was available, see `requirements/module-analysis.md` §9 |
| Sanity testing | Implicit in the smoke set, not separately tracked |
| Load / Performance / Security penetration testing | Out of scope, not attempted |

## Tools Used

| Tool | Purpose |
|---|---|
| `curl` | Every API request: creating, executing, and capturing evidence |
| PostgreSQL 17 (`psql`) | Direct database schema inspection and data validation |
| Postman (collection format) | Structured, reusable API request collection, see `api-testing/postman/` |
| Node.js / npm | Running the Medusa backend locally (`create-medusa-app`) |
| Git | Version control for this portfolio |

No automated UI framework (Playwright, Selenium, etc.). See "Automation" below for why.

## Project Structure

```
medusa/
├── README.md
├── requirements/
│   └── module-analysis.md          # Verified environment facts, modules, workflows, limitations
├── test-plan/
│   └── medusa-test-plan.md         # Scope, approach, entry/exit criteria, risks
├── test-cases/
│   ├── authentication/
│   │   ├── login-test-cases.md
│   │   └── registration-test-cases.md
│   ├── products/
│   │   └── product-test-cases.md
│   ├── carts/
│   │   └── cart-test-cases.md
│   ├── customers/
│   │   └── customer-test-cases.md
│   ├── orders/
│   │   └── order-test-cases.md
│   └── regions/
│       └── region-test-cases.md
├── api-testing/
│   ├── api-test-cases.md           # Endpoint-by-endpoint API contract verification
│   └── postman/
│       └── medusa-api-collection.json
├── database-testing/
│   └── database-test-cases.md      # Real schema + referential-integrity checks
├── test-execution/
│   ├── execution-summary.md        # Consolidated execution counts and evidence approach
│   └── screenshots/                # Empty — see README.md inside for why
├── bug-reports/
│   ├── BUG-01-decimal-quantity-rounded.md
│   ├── BUG-02-invalid-email-accepted.md
│   ├── BUG-03-negative-pagination-500.md
│   └── BUG-04-order-access-control.md
└── test-summary/
    └── test-summary-report.md      # Final metrics, findings, release assessment
```

## Test Coverage

83 test cases across 6 modules. 73 executed (68 Pass, 5 Fail), 5 Blocked (UI, no browser tool), 5 Not Executed (lower-priority boundary variants, time-boxed out). Full breakdown in [`test-execution/execution-summary.md`](test-execution/execution-summary.md).

## API Testing

Every endpoint group got the same treatment: valid requests, missing/invalid auth, invalid resource IDs, boundary and out-of-range values, plus checking the response schema and status codes against what you'd expect from standard REST semantics. Full endpoint-by-endpoint results are in [`api-testing/api-test-cases.md`](api-testing/api-test-cases.md), and there's a runnable collection at [`api-testing/postman/medusa-api-collection.json`](api-testing/postman/medusa-api-collection.json). Everything sensitive is a Postman variable (`{{access_token}}`, `{{publishable_api_key}}`); nothing's hardcoded.

## Database Testing

This actually happened, it's not a "proposed" section padded out to look thorough. A dedicated, isolated local PostgreSQL 17.11 instance ran real schema inspection and referential-integrity queries against data the API testing had actually generated (for example, confirming a completed order's `order_cart` row points back to the exact cart used at checkout). See [`database-testing/database-test-cases.md`](database-testing/database-test-cases.md). Two scenarios needing a bigger dataset or concurrent load are labeled "proposed, not executed" honestly rather than made up.

## Defect Management

Every defect in `bug-reports/` was actually reproduced, most of them more than once, with the literal request/response kept as evidence. Same fields every time: Bug ID, Title, Module, Environment, Preconditions, Steps to Reproduce, Actual/Expected Result, Severity, Priority, Reproducibility, Evidence, Status. 4 defects found, all Medium or Low severity, see [`test-summary/test-summary-report.md`](test-summary/test-summary-report.md) for the full distribution and what I'd recommend fixing first.

## Test Execution

The evidence is the literal, reproducible HTTP request/response for each test case, sitting right there in the test-case files themselves — which for API-level black-box testing is just as good as a screenshot, arguably better since anyone can replay it. UI-dependent cases are marked `Blocked`, not assumed. See [`test-execution/execution-summary.md`](test-execution/execution-summary.md).

## Key Findings

- The core commerce workflow, browse through cart through checkout through order, works correctly end-to-end. Verified at both the API and database level. No Critical or High-severity functional defects.
- Auth and authorization are strong everywhere tested, except one endpoint.
- **BUG-04** (order retrieval with no ownership check) is the finding that matters most here. Real, reproducible access-control gap, not a nitpick about design taste.
- Input validation is applied inconsistently across the API. Some fields are checked strictly, others (decimal cart quantities, registration email format, negative pagination) aren't, and that unevenness is the thread connecting the other three defects.

## QA Skills Demonstrated

- Requirements analysis built from actually exploring the app, not reading its docs and assuming.
- Risk-based test design, prioritizing authentication, checkout, and order-integrity paths.
- Positive, negative, boundary, and edge-case scenario design.
- API contract validation: status codes, schemas, error messages, auth enforcement.
- Database-level data and referential-integrity validation.
- Defect analysis with a real severity/priority call and reasoned-through exploitability (see BUG-04).
- Honest scope management: saying plainly what was verified and what wasn't, instead of padding the numbers.
- Practical environment troubleshooting, including tracking down and fixing a genuine Windows native-dependency install failure while standing up the test environment.

## Automation

Didn't build an automation framework this round, on purpose. Manual and API-first testing came first, to get accurate coverage and real findings before worrying about repeatability. The environment's stable now and the core flows (login, product listing, add-to-cart) are repeatable, so a Playwright/Pytest layer against the backend API (and the Admin UI, if a browser tool ever shows up) would be a reasonable next phase. Deliberately holding off rather than bolting it on early.
