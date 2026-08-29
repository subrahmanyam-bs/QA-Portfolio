# REST API Test Cases

**Service:** The ParaBank REST API, OpenAPI 3.0.1, v3.0.0
**Base URL:** `https://parabank.parasoft.com/parabank/services/bank`
**Spec:** [`openapi.json`](openapi.json), pulled from `/parabank/services/bank/openapi.json`
**Collection:** [`postman-collection.json`](postman-collection.json), 34 requests in 7 folders
**Tools:** Postman 11 for authoring and running, curl for capturing the evidence below
**Executed:** 2026-08-28

---

## Finding the spec

The URL normally quoted for ParaBank's API docs,
`https://parabank.parasoft.com/parabank/services/bank/api-docs`, returns **404**
with an empty body. The live spec is at
**`/parabank/services/bank/openapi.json`**, which is also what the Admin Page
links to as "OpenAPI". There's a WADL at `/parabank/services/bank?_wadl`.

Same problem on the SOAP side: `/parabank/services/bank?wsdl` is a 404, the real
one is `/parabank/services/ParaBank?wsdl`.

I've committed the retrieved spec as [`openapi.json`](openapi.json) so these tests
still work if the endpoint moves again.

## Authentication

There isn't any. Every request in this document went out with no cookie, no
`Authorization` header, no token. Every one of them worked. That's the single most
important thing about this API and it's written up as
[BUG-08](../../bug-reports/BUG-08.md).

---

## 1. Login, `GET /login/{username}/{password}`

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R01 | Valid credentials | `GET /login/john/demo` | 200 with the customer object for 12212 | High | Pass |
| TC-R02 | Right user, wrong password | `GET /login/john/wrongpass` | 400, "Invalid username and/or password" | High | Pass |
| TC-R03 | User doesn't exist | `GET /login/nosuchuser999/demo` | 400 with the same generic message, no user enumeration | High | Pass |

TC-R01 response:
```json
{"id":12212,"firstName":"John","lastName":"Smith",
 "address":{"street":"1431 Main St","city":"Beverly Hills","state":"CA","zipCode":"90210"},
 "phoneNumber":"310-447-4121","ssn":"622-11-9999"}
```

Two things wrong with that, both covered by BUG-08. The password goes in the URL
**path**, so every proxy and access log records it in clear text. And the response
hands back the customer's **SSN**. The functional assertions all pass, so the rows
stay green and the security issue is tracked separately.

Content negotiation is fine: `Accept: application/json` gives JSON, no Accept
header gives XML.

## 2. Accounts and customers

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R04 | List a customer's accounts | `GET /customers/12212/accounts` | 200, array, every element has `customerId` 12212 | High | Pass |
| TC-R05 | One account | `GET /accounts/13344` | 200, `{id, customerId, type, balance}`, type is CHECKING or SAVINGS | High | Pass |
| TC-R06 | Account id doesn't exist | `GET /accounts/99999999` | 404 | High | **Fail** - 400 with "Could not find account #99999999" ([BUG-11](../../bug-reports/BUG-11.md)) |
| TC-R07 | Account id is the wrong type | `GET /accounts/abc` | 400 naming the bad parameter | Medium | Partial pass - 404 with an empty body. Rejected, but misleading code and no message |
| TC-R08 | Customer id doesn't exist | `GET /customers/12323/accounts` | 404 | Medium | **Fail** - 400 ([BUG-11](../../bug-reports/BUG-11.md)) |
| TC-R09 | Read a different customer with no credentials | `GET /customers/17762` and `/customers/17762/accounts` | 401 | High | **Fail** - 200 with full PII and balances ([BUG-08](../../bug-reports/BUG-08.md)) |

TC-R09, sending nothing at all:
```json
{"id":17762,"firstName":"Pruthvi","lastName":"Tester",
 "address":{"street":"42 QA Street","city":"Bengaluru","state":"Karnataka","zipCode":"560001"},
 "phoneNumber":"9876543210","ssn":"123-45-6789"}
```
Customer ids are sequential, so this enumerates the whole customer base in a loop.

## 3. Transactions

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R10 | List transactions | `GET /accounts/13344/transactions` | 200, array, every row has the right `accountId` and type Debit or Credit | High | Pass, schema is correct. See the data note below |
| TC-R11 | Account doesn't exist | `GET /accounts/99999999/transactions` | 404 | Medium | **Fail** - 400 ([BUG-11](../../bug-reports/BUG-11.md)) |
| TC-R12 | Filter by amount | `GET /accounts/13344/transactions/amount/100` | 200, every row has amount 100 | Medium | Pass |
| TC-R13 | Filter by date range | `GET /accounts/13344/transactions/fromDate/01-01-2020/toDate/12-31-2026` | 200, array, MM-DD-YYYY format | Medium | Pass |
| TC-R14 | Transaction id doesn't exist | `GET /transactions/1` | 404 | Medium | **Fail** - 400 ([BUG-11](../../bug-reports/BUG-11.md)) |

Data note on TC-R10. The endpoint returns exactly what the write path stored,
which includes rows that should never have been created:

```json
{"id":29683,"accountId":13899,"type":"Credit","amount":-50.00,"description":"Funds Transfer Received"}
{"id":29461,"accountId":13899,"type":"Credit","amount":0.00,"description":"Funds Transfer Received"}
```

A Credit with a negative amount contradicts itself. The read endpoint is doing its
job, the defect is upstream in
[BUG-02](../../bug-reports/BUG-02.md) and [BUG-03](../../bug-reports/BUG-03.md).

## 4. Transfer, `POST /transfer`

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R28 | Valid transfer | `?fromAccountId=13344&toAccountId=13899&amount=100` | 200, both balances move by exactly 100.00 | High | Pass |
| TC-R29 | Negative amount | `&amount=-10` | 400, amount must be positive | High | **Fail** - 200, "Successfully transferred $-10", money goes the other way ([BUG-02](../../bug-reports/BUG-02.md)) |
| TC-R30 | Over the balance | `?fromAccountId=13899&toAccountId=13344&amount=1000000` | 400, insufficient funds | High | **Fail** - 200, source drops to **-$999,849.99** ([BUG-01](../../bug-reports/BUG-01.md)) |
| TC-R31 | Same account both sides | `?fromAccountId=13344&toAccountId=13344&amount=10` | 400 | Medium | **Fail** - 200, "from account #13344 to account #13344" ([BUG-03](../../bug-reports/BUG-03.md)) |
| TC-R32 | Destination doesn't exist | `&toAccountId=99999999&amount=10` | Rejected, nothing moves | High | Pass - 400, "Could not find account number 13344 and/or 99999999" |
| TC-R33 | Required `amount` omitted | `?fromAccountId=13344&toAccountId=13899` | 400 naming the missing parameter | High | **Fail** - 500, empty body ([BUG-11](../../bug-reports/BUG-11.md)) |
| TC-R34 | Transfer into another customer's account, no credentials | `&toAccountId=23112&amount=1` | 401 | High | **Fail** - 200, "Successfully transferred $1 from account #13344 to account #23112" ([BUG-08](../../bug-reports/BUG-08.md)) |

## 5. Create Account, `POST /createAccount`

`newAccountType`: 0 is CHECKING, 1 is SAVINGS.

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R15 | Valid creation | `?customerId=12212&newAccountType=1&fromAccountId=13344` | 200 with the documented 100.00 opening balance | High | **Fail** - 200 but the body says `"balance":0`. Re-reading the account shows 100.00 ([BUG-12](../../bug-reports/BUG-12.md)) |
| TC-R16 | Account type out of range | `&newAccountType=9` | 400 naming the bad value | Medium | **Fail** - 500, empty body ([BUG-11](../../bug-reports/BUG-11.md)) |
| TC-R17 | Required `newAccountType` omitted | `?customerId=12212&fromAccountId=13344` | 400 | High | **Fail** - 200, creates the account and defaults to CHECKING ([BUG-12](../../bug-reports/BUG-12.md)) |
| TC-R18 | Customer doesn't exist | `?customerId=99999999&...` | Rejected, nothing created | Medium | Pass - 400 |

## 6. Deposit, `POST /deposit`

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R19 | Valid deposit | `?accountId=14787&amount=50` | 200, balance up 50.00 | High | Pass |
| TC-R20 | Negative amount | `&amount=-500` | 400 | High | **Fail** - 200, "Successfully deposited $-500". Acts as a withdrawal |
| TC-R21 | Zero | `&amount=0` | 400 | Medium | **Fail** - 200, "Successfully deposited $0" |
| TC-R22 | Wrong data type | `&amount=abc` | 400 naming the bad parameter | Medium | Partial pass - rejected with 404 and an empty body |
| TC-R23 | Required `amount` omitted | `?accountId=14787` | 400 | High | **Fail** - 500, empty body ([BUG-11](../../bug-reports/BUG-11.md)) |
| TC-R24 | Account doesn't exist | `?accountId=99999999&amount=50` | Rejected | Medium | Pass - 400, "Could not find account number 99999999" |

## 7. Withdraw, `POST /withdraw`

| TC ID | Scenario | Request | Expected | Priority | Status |
|-------|----------|---------|----------|----------|--------|
| TC-R25 | Valid withdrawal | `?accountId=14787&amount=50` | 200, balance down 50.00 | High | Pass |
| TC-R26 | More than the balance | `&amount=100000` | 400, insufficient funds | High | **Fail** - 200, 14787 drops to **-$100,375.00** ([BUG-01](../../bug-reports/BUG-01.md) family) |
| TC-R27 | Negative amount | `&amount=-25` | 400 | High | **Fail** - 200, "Successfully withdrew $-25". Acts as a deposit |

---

## Results

| Result | Count |
|--------|-------|
| Pass | 16, three of them partial (rejected, but wrong status code or empty body) |
| Fail | 18 |
| **Total** | **34** |

### Failures grouped by cause

Eighteen failures, six actual problems.

| Cause | Cases | Bug |
|-------|-------|-----|
| No auth or ownership check anywhere | R09, R34 | [BUG-08](../../bug-reports/BUG-08.md) |
| Nobody checks the sign or minimum of an amount | R20, R21, R27, R29 | [BUG-02](../../bug-reports/BUG-02.md) |
| Nobody checks the balance before debiting | R26, R30 | [BUG-01](../../bug-reports/BUG-01.md) |
| No same-account check on transfer | R31 | [BUG-03](../../bug-reports/BUG-03.md) |
| Wrong status codes, 400 for not-found and 500 for bad input | R06, R08, R11, R14, R16, R23, R33 | [BUG-11](../../bug-reports/BUG-11.md) |
| createAccount response payload and required params | R15, R17 | [BUG-12](../../bug-reports/BUG-12.md) |

### Non-functional notes

- Response times were 0.44s to 0.98s over the public internet. The collection
  asserts a 3000ms ceiling and nothing came close to breaching it.
- No rate limiting on anything, including `login`.
- Content negotiation via `Accept` works properly for both JSON and XML.

## Running the collection

```bash
# GUI: import postman-collection.json into Postman, then Run collection

# CLI
npm install -g newman
newman run postman-collection.json -r cli,html
```

Collection variables (`baseUrl`, `username`, `password`, `customerId`,
`accountId` and so on) are pre-filled from
[`../../docs/test-data.md`](../../docs/test-data.md).

**A clean run will show failures, and that's intentional.** The assertions written
against known defects are deliberately red, and each one names its BUG id in the
test message. That makes the collection a regression suite: fix a defect and its
test goes green.

Two caveats before you run it. Requests marked WARNING move money in the shared
sandbox, so put the balances back afterwards. And accounts 13344 and 13899 are
currently unreadable because of [BUG-15](../../bug-reports/BUG-15.md), so swap the
`accountId`, `fromAccountId` and `toAccountId` variables for healthy accounts
until the database gets reseeded.
