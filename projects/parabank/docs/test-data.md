# Test Data

Everything here is public demo data from Parasoft's ParaBank sandbox. Nothing is
real or sensitive. ParaBank ships with one fictional customer, and every account I
created uses invented names and made-up numbers.

> ParaBank is a **shared public sandbox**. Anyone can register, anyone can wipe it
> from the Admin page, and Parasoft resets it periodically. The balances and
> account IDs below are what I observed on 2026-08-28, not guarantees. Test cases
> read the current balance first rather than assuming a fixed one, because other
> testers move money while you're working. I watched 13899 change between two of
> my own runs.

---

## 1. Built-in demo login

ParaBank ships with one seeded customer. The app publishes the credentials
itself, the OpenAPI document labels the login operation `Login (john/demo)`.

| Field | Value |
|-------|-------|
| Username | `john` |
| Password | `demo` |
| Customer ID | `12212` |
| Name | John Smith |
| Address | 1431 Main St, Beverly Hills, CA 90210 |
| Phone | 310-447-4121 |

## 2. Accounts

Starting state for customer 12212 on 2026-08-28:

| Account # | Type | Starting balance | What I used it for |
|-----------|------|------------------|--------------------|
| 13344 | CHECKING | $4222.93 | Main "from" account: transfers, bill pay, loan funding |
| 13899 | SAVINGS | $100.00 | Main "to" account for transfers |
| 14232 | SAVINGS | $100.00 | Second destination |
| 14565 | SAVINGS | $100.00 | Payee account for Bill Pay |
| 14787 | SAVINGS | $100.00 | Deposit and withdraw API tests |
| 15675, 15897, 16008, 16119 | SAVINGS | $100.00 each | Boundary and overdraft tests |

Created by these tests, so expect them on a database that hasn't been reset:
`31104`, `31326`, `33102`, `33324`.

> ### Current state warning
>
> **13344 and 13899 are currently unreadable.** A transfer of `100.999` corrupted
> both, and every read on them now returns HTTP 500, which also breaks the
> Accounts Overview page for customer 12212. Full detail in
> [BUG-15](../bug-reports/BUG-15.md).
>
> This can't be repaired through the app, every write reads the account first. The
> only fix is Admin Page -> INITIALIZE, which reseeds the whole database and would
> destroy other people's in-flight data. I've left it alone deliberately.
>
> **If you're re-running these tests**, either wait for Parasoft's periodic reset
> or substitute two healthy accounts from the list above. The other nine still
> respond normally.

## 3. Test users I registered

| Username | Password | Customer ID | Why it exists |
|----------|----------|-------------|---------------|
| `qatester_2608` | `Test@1234` | 17762 | Happy path registration. Reused for the duplicate-username case and cross-validation |
| `neg_ssn_2608` | `Test@1234` | - | Proves SSN format isn't validated, `abcdefghi` was accepted |
| `neg_phone_2608` | `Test@1234` | - | Proves phone format isn't validated, `not-a-phone` was accepted |
| `neg_zip_2608` | `Test@1234` | - | Proves zip format isn't validated, `ABCDE!!` was accepted |
| `neg_ws_2608` | `Test@1234` | - | Proves a whitespace-only first name is accepted |
| `neg_weakpw_2608` | `1` | - | Proves a 1-character password is accepted |

Happy path registration payload:

| Field | Value |
|-------|-------|
| First Name | Pruthvi |
| Last Name | Tester |
| Address | 42 QA Street |
| City | Bengaluru |
| State | Karnataka |
| Zip Code | 560001 |
| Phone # | 9876543210 |
| SSN | 123-45-6789 (invented, not a real SSN) |

## 4. Amounts

Fixed values, reused so results are comparable between runs.

| Purpose | Amount |
|---------|--------|
| Standard valid transfer | `100.00` |
| Cross-validation transfer, API to UI | `200.00` |
| Standard valid bill payment | `25.00` |
| Cross-validation bill payment, UI to API | `30.00` |
| Lower boundary | `0.01` |
| Zero boundary | `0` |
| Negative boundary | `-50` |
| Over balance | `999999` |
| Three decimal places (destructive, see BUG-15) | `100.999` |
| Minimum opening deposit per the UI | `100.00` |

## 5. Standard payee for Bill Pay

| Field | Value |
|-------|-------|
| Payee Name | QA Electric Company |
| Address | 9 Utility Lane |
| City | Bengaluru |
| State | Karnataka |
| Zip Code | 560002 |
| Phone # | 9998887777 |
| Account # and Verify Account # | 14565 |

## 6. Dates

Find Transactions wants **MM-DD-YYYY**. Date range API tests use
`fromDate=01-01-2020` and `toDate=12-31-2026` to cover all seeded activity.

## 7. Endpoints

| Interface | URL |
|-----------|-----|
| REST base | `https://parabank.parasoft.com/parabank/services/bank` |
| OpenAPI 3.0 spec | `https://parabank.parasoft.com/parabank/services/bank/openapi.json` |
| SOAP endpoint | `https://parabank.parasoft.com/parabank/services/ParaBank` |
| WSDL | `https://parabank.parasoft.com/parabank/services/ParaBank?wsdl` |
| UI AJAX proxy | `https://parabank.parasoft.com/parabank/services_proxy/bank` |

## 8. Cleaning up after yourself

Several negative tests deliberately push balances far out of range. One account
hit **-$999,848.99**. After each destructive run I put the affected accounts back
to their starting balances using the REST `deposit` and `withdraw` endpoints, so
the sandbox stays usable for whoever's on it next.

The exception is the pair broken by BUG-15, which can't be restored by any means
the application offers.
