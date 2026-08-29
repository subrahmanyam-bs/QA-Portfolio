# ParaBank - Functional and API Testing

Functional testing of [ParaBank](https://parabank.parasoft.com/parabank/index.htm),
Parasoft's public demo banking application, across the web UI, the REST API and
the SOAP API.

Every test case here was run against the live application, and every defect was
reproduced before it was written up.

---

## Objective

Cover a full test cycle on a live banking application: explore and scope it,
design positive, negative and boundary cases, execute them, raise reproducible
defect reports, exercise both service interfaces, and confirm the UI and the API
actually agree on the same data.

## Scope

| Area | Covered |
|------|---------|
| Public UI | Home / Customer Login, Register, Forgot Login Info, About Us, Services, Contact Us, Site Map, Admin Page |
| Authenticated UI | Accounts Overview, Open New Account, Transfer Funds, Bill Pay, Find Transactions, Update Contact Info, Request Loan, Account Activity, Log Out |
| REST API | Login, Get Customer, Get Accounts, Get Transactions (by id, amount, date range), Transfer, Create Account, Deposit, Withdraw |
| SOAP API | `login` and `getAccount`, from the 27 operations in the WSDL |
| Cross-validation | Six end-to-end checks reconciling UI actions against API state and back |

Full scope with paths: [`docs/test-scope.md`](docs/test-scope.md)

Not covered: performance, load and accessibility. Trading and position operations
(no UI counterpart). Find Transactions and Request Loan are documented in the
scope but have no test cases this round.

## Tools

| Tool | Used for |
|------|----------|
| ParaBank public demo | Application under test |
| Chrome 141 on Windows 11 | UI execution, DevTools, screenshots |
| Postman 11 | REST collection, request execution, assertions |
| Newman | Running the collection from the CLI |
| SoapUI 5.7 Open Source | WSDL inspection, SOAP request scaffolding |
| curl 8.x | Capturing reproducible request/response evidence |
| Markdown and Git | Test cases, bug reports, version control |

---

## Results

| Metric | Count |
|--------|-------|
| **Total test cases executed** | **91** |
| Passed | 56 |
| Failed | 35 |
| Pass rate | 62% |

| Suite | Executed | Passed | Failed |
|-------|----------|--------|--------|
| UI, Registration | 11 | 6 | 5 |
| UI, Login | 9 | 8 | 1 |
| UI, Transfer Funds | 13 | 6 | 7 |
| UI, Bill Pay | 10 | 7 | 3 |
| REST API | 34 | 16 | 18 |
| SOAP API | 8 | 8 | 0 |
| Cross-validation | 6 | 5 | 1 |
| **Total** | **91** | **56** | **35** |

### Defects

| Metric | Count |
|--------|-------|
| **Bugs found** | **15** |
| High | 6 |
| Medium | 6 |
| Low | 3 |

| ID | Title | Module | Severity |
|----|-------|--------|----------|
| [BUG-01](bug-reports/BUG-01.md) | Transfer goes through when the amount exceeds the balance | Transfer Funds | High |
| [BUG-02](bug-reports/BUG-02.md) | Transfer takes a negative amount and sends the money the other way | Transfer Funds | High |
| [BUG-03](bug-reports/BUG-03.md) | Transfer accepts zero, and allows self-transfer, which is the default state | Transfer Funds | Medium |
| [BUG-04](bug-reports/BUG-04.md) | Result panel shows success and an empty "Error!" together | Transfer Funds | Low |
| [BUG-05](bug-reports/BUG-05.md) | Bill Pay lets you pay more than the account holds | Bill Pay | High |
| [BUG-06](bug-reports/BUG-06.md) | Bill Pay accepts a negative amount, paying the customer | Bill Pay | High |
| [BUG-07](bug-reports/BUG-07.md) | Bill Pay accepts a zero-amount payment | Bill Pay | Medium |
| [BUG-08](bug-reports/BUG-08.md) | REST and SOAP have no auth. SSN and balances readable, money movable | REST / SOAP | High |
| [BUG-09](bug-reports/BUG-09.md) | Registration doesn't validate SSN, Phone or Zip format | Registration | Medium |
| [BUG-10](bug-reports/BUG-10.md) | Protected pages return 500 instead of redirecting to login | Session management | Medium |
| [BUG-11](bug-reports/BUG-11.md) | REST returns 400 for not-found and 500 for missing parameters | REST API | Medium |
| [BUG-12](bug-reports/BUG-12.md) | createAccount reports balance 0 for an account opened with $100 | REST API | Medium |
| [BUG-13](bug-reports/BUG-13.md) | No password policy, and Phone # required in Bill Pay but not Registration | Registration | Low |
| [BUG-14](bug-reports/BUG-14.md) | Admin Page is public and needs no login | Admin Page | Low |
| [BUG-15](bug-reports/BUG-15.md) | A 3-decimal amount permanently corrupts both accounts in the transfer | Transfer Funds | High |

### What the 35 failures actually are

They aren't 35 separate problems. They collapse into six causes, which is the more
useful way to hand this to a developer:

| Cause | Failing tests | Bugs |
|-------|---------------|------|
| Nobody validates a monetary amount: sign, zero, or decimal scale | 12 | BUG-02, BUG-03, BUG-06, BUG-07, BUG-15 |
| No insufficient-funds check on any debit path | 4 | BUG-01, BUG-05 |
| No authentication or authorization on the service layer | 3 | BUG-08 |
| Wrong HTTP status codes, unhandled exceptions on bad input | 8 | BUG-11 |
| No input format validation on registration | 5 | BUG-09, BUG-13 |
| Response payload and error handling defects | 3 | BUG-04, BUG-10, BUG-12 |

Three worth reading first:

**BUG-15.** Transfer `100.999` and both accounts become permanently unreadable.
Every subsequent read returns HTTP 500, which takes the Accounts Overview page
down with it. SOAP gave up the root cause: `Rounding necessary`, a
`BigDecimal.setScale(2)` with no RoundingMode. No repair is possible through the
application, because every write reads the account first.

**BUG-01.** No balance check anywhere. A transfer of $999,999 from an account
holding $150 went through the normal UI and left it at -$999,848.99.

**BUG-08.** The API has no authentication at all. Any customer's name, address,
phone and SSN come back by incrementing an integer in a URL, and money moves
between accounts belonging to different customers on an unauthenticated request.

ParaBank is published by Parasoft as a **deliberately imperfect** training app, so
some of this is intentional teaching material. It's reported here the way it would
be against a real product.

---

## Folder layout

```
parabank/
  README.md                     you are here

  docs/
    test-scope.md               every module found, with paths
    test-data.md                credentials, accounts, amounts, endpoints
                                (read the "current state warning" before re-running)

  test-cases/                   UI test cases, TC ID tables
    registration.md             11 cases
    login.md                     9 cases
    fund-transfer.md            13 cases
    bill-pay.md                 10 cases

  bug-reports/                  one file per defect
    BUG-01.md ... BUG-15.md

  api-testing/
    rest/
      postman-collection.json   34 requests, 7 folders, Newman-ready
      rest-api-test-cases.md    TC-R01 to TC-R34 with real responses
      openapi.json              the retrieved OpenAPI 3.0.1 spec
    soap/
      soap-api-test-cases.md    TC-S01 to TC-S08 with real envelopes
      parabank.wsdl             the retrieved WSDL

  cross-validation/
    ui-api-integration-tests.md TC-X01 to TC-X06

  screenshots/                  evidence by module
    registration/  login/  fund-transfer/  bill-pay/  open-account/  admin/
```

Suggested reading order:

1. [`docs/test-scope.md`](docs/test-scope.md), what the app is and what got covered
2. [`test-cases/fund-transfer.md`](test-cases/fund-transfer.md), the richest UI suite
3. [`bug-reports/BUG-15.md`](bug-reports/BUG-15.md) and [`BUG-08.md`](bug-reports/BUG-08.md), the two most interesting finds
4. [`api-testing/rest/rest-api-test-cases.md`](api-testing/rest/rest-api-test-cases.md), API coverage with real evidence
5. [`cross-validation/ui-api-integration-tests.md`](cross-validation/ui-api-integration-tests.md)

## Running the API tests

```bash
npm install -g newman
newman run api-testing/rest/postman-collection.json -r cli,html
```

Assertions written against known defects are deliberately red, and each names its
BUG id. Fix a defect and its test turns green, so the collection works as a
regression suite.

Two things before you run it. Requests marked WARNING move money on a shared
sandbox, so restore the balances afterwards. And accounts 13344 and 13899 are
currently unreadable because of BUG-15, so point the collection variables at
healthy accounts until Parasoft reseeds the database.

## Notes on the environment

ParaBank is a shared public sandbox. Data you create is visible to everyone,
anyone can wipe it from the Admin page, and Parasoft resets it periodically.
Account numbers and balances in `docs/test-data.md` are what I saw on 2026-08-28.
Balances drift between runs because other people are testing at the same time.

Destructive negative tests were reversed afterwards using the REST deposit and
withdraw endpoints, so the sandbox stays usable. The two accounts broken by BUG-15
are the exception, nothing the application offers can repair them.

The spec URLs usually quoted for ParaBank
(`.../services/bank/api-docs` and `.../services/bank?wsdl`) both return 404. The
working ones are `/parabank/services/bank/openapi.json` and
`/parabank/services/ParaBank?wsdl`. Both retrieved documents are committed here so
this stays reproducible.

## License

MIT. See the LICENSE file at the root of this repository.
