## Bug ID: BUG-01

**Title:** Transfer goes through even when the amount is bigger than the available balance, leaving the account deeply negative

**Module:** Transfer Funds. Same behaviour on `POST /services/bank/transfer`.

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Preconditions:** Logged in as john/demo. Account 13899 holds $150.01.

**Steps to Reproduce:**
1. Log in as john/demo
2. Transfer Funds
3. Amount = `999999`
4. From = 13899 ($150.01), To = 13344
5. TRANSFER
6. Check Accounts Overview, or `GET /parabank/services/bank/accounts/13899`

**Expected Result:**
Rejected with an insufficient funds message. No transaction written, 13899
unchanged. A customer-initiated transfer shouldn't be able to push a retail
account below zero at all, let alone by six figures.

**Actual Result:**
"Transfer Complete! $999,999.00 has been transferred from account #13899 to
account #13344."

Committed, and 13899 lands at **-$999,848.99**:

```
GET /parabank/services/bank/accounts/13899
{"id":13899,"customerId":12212,"type":"SAVINGS","balance":-999848.99}
```

No overdraft limit, no warning, no reversal. Nothing anywhere in the flow checks
the source balance.

**Severity:** High

**Also affects:** Bill Pay ([BUG-05](BUG-05.md)) and `POST /withdraw` (TC-R26).
Three entry points, one missing check, so the gap is in the service layer rather
than in any one page.

**Screenshot:** [screenshots/fund-transfer/02-transfer-success.jpg](../screenshots/fund-transfer/02-transfer-success.jpg)
shows the confirmation panel format. Balance evidence is the API call above.
