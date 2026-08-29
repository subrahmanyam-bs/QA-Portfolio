# ParaBank - Test Scope

**Application under test:** ParaBank, Parasoft's public demo banking app
**Base URL:** https://parabank.parasoft.com/parabank/index.htm
**Explored:** 2026-08-28

ParaBank is published by Parasoft as a deliberately imperfect banking app for
testing and training. Everything below came from clicking through the live site,
not from documentation.

---

## 1. Public pages, no login needed

| # | Module | Path | Notes |
|---|--------|------|-------|
| 1 | Home / Customer Login | `/parabank/index.htm` | Username and Password panel, repeated on every public page |
| 2 | Register | `/parabank/register.htm` | 11 fields: First/Last Name, Address, City, State, Zip, Phone, SSN, Username, Password, Confirm |
| 3 | Forgot Login Info | `/parabank/lookup.htm` | Recovers username and password from personal details |
| 4 | About Us | `/parabank/about.htm` | Static |
| 5 | Services | `/parabank/services.htm` | Static, describes the SOAP and REST services |
| 6 | Contact Us | `/parabank/contact.htm` | Name, email, phone, message |
| 7 | Site Map | `/parabank/sitemap.htm` | Index of everything |
| 8 | Admin Page | `/parabank/admin.htm` | Opens without login. See section 4 |

## 2. Behind login (Account Services menu)

Explored as john/demo, customer ID **12212**.

| # | Module | Path | Key elements |
|---|--------|------|--------------|
| 9 | Accounts Overview | `/parabank/overview.htm` | Landing page after login. Account / Balance / Available Amount, plus a total |
| 10 | Open New Account | `/parabank/openaccount.htm` | Account type CHECKING or SAVINGS, funding account dropdown, $100 minimum |
| 11 | Transfer Funds | `/parabank/transfer.htm` | Amount, From account, To account |
| 12 | Bill Pay | `/parabank/billpay.htm` | Payee name/address/city/state/zip/phone, Account #, Verify Account #, Amount, From account |
| 13 | Find Transactions | `/parabank/findtrans.htm` | Four separate searches: by Transaction ID, by Date, by Date Range, by Amount. Dates are MM-DD-YYYY |
| 14 | Update Contact Info | `/parabank/updateprofile.htm` | First/Last Name, Address, City, State, Zip, Phone |
| 15 | Request Loan | `/parabank/requestloan.htm` | Loan Amount, Down Payment, From account |
| 16 | Account Activity | `/parabank/activity.htm?id={accountId}` | Reached by clicking an account number in the overview |
| 17 | Transaction Details | `/parabank/transaction.htm?id={txnId}` | Reached from a Find Transactions result |
| 18 | Log Out | `/parabank/logout.htm` | Ends the session, back to Home |

## 3. Service layer

| Interface | Endpoint | Contract |
|-----------|----------|----------|
| REST | `/parabank/services/bank` | OpenAPI 3.0.1 at `/parabank/services/bank/openapi.json` |
| REST (WADL) | same | `/parabank/services/bank?_wadl` |
| SOAP | `/parabank/services/ParaBank` | WSDL at `/parabank/services/ParaBank?wsdl` |
| SOAP (LoanProcessor) | `/parabank/services/store-01` | Separate service, out of scope |
| UI AJAX proxy | `/parabank/services_proxy/bank` | What transfer.htm and billpay.htm actually call |

REST exposes 27 operations: `login`, `accounts/{id}`, `customers/{id}`,
`customers/{id}/accounts`, `accounts/{id}/transactions` plus filters by amount,
month and type, date range and single date, `transactions/{id}`, `transfer`,
`deposit`, `withdraw`, `billpay`, `createAccount`, `requestLoan`,
`customers/update/{id}`, the position/trading operations, and admin operations
(`initializeDB`, `cleanDB`, `setParameter`, JMS listener start and stop).

SOAP exposes 27 operations under namespace `http://service.parabank.parasoft.com/`:
`login`, `getAccount`, `getAccounts`, `getCustomer`, `getTransaction`,
`getTransactions`, `getTransactionsByAmount`, `getTransactionsByMonthAndType`,
`getTransactionsByToFromDate`, `getTransactionsOnDate`, `transfer`, `deposit`,
`withdraw`, `billPay`, `createAccount`, `requestLoan`, `updateCustomer`,
`buyPosition`, `sellPosition`, `getPosition`, `getPositions`,
`getPositionHistory`, `initializeDB`, `cleanDB`, `setParameter`,
`startupJmsListener`, `shutdownJmsListener`.

---

## 4. Things worth knowing before you start testing here

Noted while mapping the app. Each one is followed up in a test case or a bug
report.

**The Admin Page link is public.** No login required. It exposes database
Initialize and Clean, JMS shutdown, data access mode switching, and global
settings like initial balance, minimum balance and loan processor rules. Practical
consequence for testers: another person hitting CLEAN mid-session will wipe your
data underneath you.

**The documented spec URLs are wrong.** `/parabank/services/bank/api-docs`
returns 404. The live OpenAPI document is at
`/parabank/services/bank/openapi.json`. Same story on the SOAP side,
`/parabank/services/bank?wsdl` returns 404 and the real WSDL is at
`/parabank/services/ParaBank?wsdl`. Both retrieved files are committed under
`api-testing/` so this stays reproducible if they move again.

**`GET /services/bank/login/{username}/{password}` takes the password in the URL
path and returns the customer's SSN and home address**, with no token or session
of any kind. See [BUG-08](../bug-reports/BUG-08.md).

**It's a shared public sandbox.** Anything you create is visible to everyone, and
anyone can wipe it. Test data has to tolerate records it didn't create, and
balances drift between runs because other people are moving money at the same
time. I saw account 13899 change value between two of my own test runs.

**Transfer Funds and Bill Pay are AJAX.** They post to `services_proxy` and swap
panels in place, no page navigation. If you automate them, there's no page load to
wait on.

**One field has a randomised id.** `payee.phoneNumber` on billpay.htm gets a new
UUID as its `id` on every page load. Locate it by `name`.

---

## 5. Out of scope

- Products and Locations menu items, both external links to parasoft.com
- Forum, external phpBB instance
- Position and trading operations on SOAP and REST, no UI counterpart in ParaBank
- Performance, load and accessibility testing
- Find Transactions and Request Loan were explored and documented above, but no
  test cases were written for them. The four modules in `test-cases/` were the
  agreed scope for this round
