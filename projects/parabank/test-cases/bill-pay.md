# Test Cases - Bill Pay

**Module:** Bill Payment Service
**URL:** https://parabank.parasoft.com/parabank/billpay.htm
**Executed:** 2026-08-28
**Preconditions:** Logged in as john/demo.

AJAX driven like Transfer Funds. SEND PAYMENT posts the payee as a JSON body to
`POST /parabank/services_proxy/bank/billpay?accountId=&amount=`.

**Standard payee used below:** QA Electric Company, 9 Utility Lane, Bengaluru,
Karnataka, 560002, phone 9998887777, Account # 14565.

> **Automation gotcha:** the `payee.phoneNumber` input gets a fresh random `id` on
> every page load, e.g. `22dbbeb3-cef1-45fb-8922-edb40f091e56`. Locate it by
> `name`. An id-based locator will pass once and then break.

| TC ID | Scenario | Steps | Expected Result | Priority | Status |
|-------|----------|-------|-----------------|----------|--------|
| TC01 | Valid payment | 1. Open billpay.htm<br>2. Standard payee<br>3. Account # 14565, Verify 14565<br>4. Amount `25`, From 13344<br>5. SEND PAYMENT | "Bill Payment Complete - Bill Payment to QA Electric Company in the amount of $25.00 from account 13344 was successful." | High | Pass |
| TC02 | Submit the form empty | 1. Open billpay.htm<br>2. SEND PAYMENT | Every mandatory field flagged | High | Pass - all 8 payee fields plus "The amount cannot be empty.", and unlike Registration it does flag Phone # |
| TC03 | Account # and Verify don't match | 1. Standard payee<br>2. Account # 14565, Verify 99999<br>3. Amount `10`<br>4. SEND PAYMENT | Rejected with "The account numbers do not match." | High | Pass |
| TC04 | Non-numeric amount | 1. Standard payee<br>2. Amount `abc`<br>3. SEND PAYMENT | Rejected with "Please enter a valid amount." | Medium | Pass |
| TC05 | Non-numeric payee account number | 1. Standard payee<br>2. Account # and Verify both `abcdef`<br>3. Amount `5`<br>4. SEND PAYMENT | "Please enter a valid number." on both account fields | Medium | Pass |
| TC06 | Negative amount | 1. Standard payee<br>2. Amount `-75`, From 16008<br>3. SEND PAYMENT | Rejected as invalid | High | **Fail** - "in the amount of $-75.00 ... was successful". The payer's balance goes **up** by $75 ([BUG-06](../bug-reports/BUG-06.md)) |
| TC07 | Zero amount | 1. Standard payee<br>2. Amount `0`<br>3. SEND PAYMENT | Rejected. A $0.00 payment is meaningless | Medium | **Fail** - reported successful, writes a $0.00 debit ([BUG-07](../bug-reports/BUG-07.md)) |
| TC08 | Payment over available balance | 1. Standard payee<br>2. From 16119 (holds $100.00)<br>3. Amount `500000`<br>4. SEND PAYMENT | Rejected, insufficient funds | High | **Fail** - goes through. 16119 ends at **-$499,900.00** ([BUG-05](../bug-reports/BUG-05.md)) |
| TC09 | Source is debited and the payment is logged | 1. Note the balance of 13344<br>2. Run TC01<br>3. Reopen Accounts Overview, click 13344 | Balance down exactly $25.00, and a debit described "Bill Payment to QA Electric Company" appears in Account Activity | High | Pass |
| TC10 | Payee account can be one of your own | 1. Standard payee with Account # 14565, an account john owns<br>2. Amount `25`, From 13344<br>3. SEND PAYMENT | Accepted. ParaBank has no payee registry, so any account number is a valid target | Low | Pass, documenting expected behaviour rather than a defect |

## Summary

| Result | Count |
|--------|-------|
| Pass | 7 |
| Fail | 3 |
| **Total** | **10** |

Bill Pay validates noticeably better than Transfer Funds. It catches non-numeric
amounts, mismatched account numbers, non-numeric account numbers, and every
missing field, all with proper field-level messages.

What it misses is the same thing Transfer misses: nobody checks the sign of the
amount or whether the money is actually there. Both modules call the same
service, so TC06 and TC08 are the same underlying gap reached from a second
entry point.

**Evidence:** `screenshots/bill-pay/`
