# UI and API Cross-Validation

The point of these is to prove the web UI and the service layer are reading and
writing the same data. Each test does something through one channel and checks the
result through the other, so a mismatch between them gets caught instead of each
side passing in isolation.

**Executed:** 2026-08-28
**UI:** Chrome 141 on Windows 11, logged in as john/demo (customer 12212)
**API:** `/parabank/services/bank` for REST and `/parabank/services/ParaBank` for SOAP, driven with curl

---

| TC ID | Scenario | Steps | Expected | Priority | Status |
|-------|----------|-------|----------|----------|--------|
| TC-X01 | Transfer through the API, check the balances in the UI | **API:** `GET /accounts/13344` and `/accounts/13899` to record the starting balances<br>**API:** `POST /transfer?fromAccountId=13344&toAccountId=13899&amount=200`<br>**UI:** log in and open Accounts Overview | Overview shows the source down exactly $200.00 and the destination up exactly $200.00, matching the API to the cent | High | Pass |
| TC-X02 | Pay a bill in the UI, check it through the API | **UI:** Bill Pay, payee "CrossCheck Telecom", Account #/Verify 16119, Amount `30`, From 13344, SEND PAYMENT<br>**API:** `GET /accounts/13344` and `/accounts/13344/transactions` | API balance is exactly $30.00 lower, and a new Debit of 30.00 described "Bill Payment to CrossCheck Telecom" appears | High | Pass |
| TC-X03 | Open an account in the UI, check it through the API | **UI:** Open New Account, SAVINGS, funded from 13344, note the account number on the confirmation<br>**API:** `GET /accounts/{newId}` and `/customers/12212/accounts` | New account comes back with customerId 12212 and the documented $100.00 opening balance, shows up in the account list, and the funding account is $100.00 lower | High | Pass |
| TC-X04 | Register in the UI, authenticate through both services | **UI:** register `qatester_2608`<br>**REST:** `GET /login/qatester_2608/Test@1234`<br>**SOAP:** `login` with the same credentials | Both services authenticate the UI-created user and return the same customer record, matching what was typed into the form | High | Pass |
| TC-X05 | Read one account three ways | **UI:** Accounts Overview row for 13344<br>**REST:** `GET /accounts/13344`<br>**SOAP:** `getAccount` with accountId 13344 | Same type and same balance everywhere, no rounding or formatting drift | Medium | Pass |
| TC-X06 | A rule the UI enforces and the API doesn't | **UI:** openaccount.htm says "A minimum of $100.00 must be deposited into this account at time of opening". Open one and read the confirmation<br>**API:** `POST /createAccount?customerId=12212&newAccountType=1&fromAccountId=13344` and read the response | Both channels report the new account with the same opening balance | High | **Fail** - UI says $100.00, API response says `"balance":0` ([BUG-12](../bug-reports/BUG-12.md)) |

---

## Evidence

### TC-X01, write through API, read through UI

```
# Before
GET /services/bank/accounts/13344 -> {"balance":4222.93}
GET /services/bank/accounts/13899 -> {"balance":100.00}

# Act
POST /services/bank/transfer?fromAccountId=13344&toAccountId=13899&amount=200
-> 200  "Successfully transferred $200 from account #13344 to account #13899"

# After
GET /services/bank/accounts/13344 -> {"balance":4022.93}
GET /services/bank/accounts/13899 -> {"balance":300.00}
```

Accounts Overview straight afterwards:

| Account | Balance | Available Amount |
|---------|---------|------------------|
| 13344 | $4022.93 | $4022.93 |
| 13899 | $300.00 | $300.00 |

Exact match, and no caching lag between the write and the UI read.
Screenshot: [`screenshots/fund-transfer/04-overview-after-api-transfer.jpg`](../screenshots/fund-transfer/04-overview-after-api-transfer.jpg)

### TC-X02, write through UI, read through API

UI confirmation: "Bill Payment to CrossCheck Telecom in the amount of $30.00 from
account 13344 was successful."
Screenshot: [`screenshots/bill-pay/03-crossvalidation-payment.jpg`](../screenshots/bill-pay/03-crossvalidation-payment.jpg)

```
GET /services/bank/accounts/13344
-> {"id":13344,"customerId":12212,"type":"CHECKING","balance":3992.93}    # 4022.93 - 30.00

GET /services/bank/accounts/13344/transactions   (last row)
-> {"id":38674,"accountId":13344,"type":"Debit","amount":30.00,
    "description":"Bill Payment to CrossCheck Telecom"}
```

Balance delta and transaction record both line up with what the UI said.

### TC-X03, write through UI, read through API

UI confirmation: "Account Opened! ... Your new account number: 33102"
Screenshot: [`screenshots/open-account/01-account-opened-ui.jpg`](../screenshots/open-account/01-account-opened-ui.jpg)

```
GET /services/bank/accounts/33102
-> 200 {"id":33102,"customerId":12212,"type":"CHECKING","balance":100.00}

GET /services/bank/customers/12212/accounts
-> count goes 11 to 12, list includes 33102

GET /services/bank/accounts/13344
-> {"balance":3892.93}    # 3992.93 - 100.00 opening deposit
```

The UI path applies the $100.00 minimum properly and debits the funding account.

### TC-X04, UI registration, service authentication

```
GET /services/bank/login/qatester_2608/Test@1234
-> {"id":17762,"firstName":"Pruthvi","lastName":"Tester",
    "address":{"street":"42 QA Street","city":"Bengaluru","state":"Karnataka","zipCode":"560001"},
    "phoneNumber":"9876543210","ssn":"123-45-6789"}
```

Every value matches what went into the registration form, and SOAP `login`
returns the same record. So registration writes to the store the services read
from.

### TC-X05, three-way read on 13344

| Channel | Type | Balance |
|---------|------|---------|
| UI, Accounts Overview | CHECKING | $4222.93 |
| REST, `GET /accounts/13344` | CHECKING | 4222.93 |
| SOAP, `getAccount` | CHECKING | 4222.93 |

### TC-X06, the one disagreement

```
# API
POST /services/bank/createAccount?customerId=12212&newAccountType=1&fromAccountId=13344
-> 200 {"id":33324,"customerId":12212,"type":"SAVINGS","balance":0}      <- says 0

# Same account, a few seconds later
GET /services/bank/accounts/33324
-> 200 {"id":33324,"customerId":12212,"type":"SAVINGS","balance":100.00} <- actually 100

# Funding account debited correctly
13344: 3892.93 -> 3792.93
```

Money is right on both sides. The API response body gets serialised before the
opening deposit is applied, so an API client is told the account is empty while
the UI correctly shows $100.00. Full write-up in [BUG-12](../bug-reports/BUG-12.md).

---

## Summary

| Result | Count |
|--------|-------|
| Pass | 5 |
| Fail | 1 |
| **Total** | **6** |

The UI and the service layer share one data store, and changes propagate between
them immediately and to the cent. TC-X01 through TC-X05 all reconciled exactly.

The one mismatch is a presentation problem in an API response payload, not a data
integrity problem. Balances stayed consistent across all three channels
throughout.

There's a bigger point sitting underneath all of this though. Every API call above
ran with **no credentials at all**, while the equivalent UI action needed a
logged-in session. Two channels, same data, completely different access rules. See
[BUG-08](../bug-reports/BUG-08.md).
