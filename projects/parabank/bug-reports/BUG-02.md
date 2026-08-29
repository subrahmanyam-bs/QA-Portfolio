## Bug ID: BUG-02

**Title:** Transfer takes a negative amount and quietly sends the money the other way

**Module:** Transfer Funds. Reproduces on `POST /services/bank/transfer` too.

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Steps to Reproduce:**
1. Log in as john/demo
2. Transfer Funds
3. Amount = `-50`
4. From = 13344, To = 14232
5. TRANSFER
6. Compare both balances in Accounts Overview

**Expected Result:**
The Amount field rejects negatives, something like "Please enter an amount
greater than zero." Nothing is committed.

**Actual Result:**
"Transfer Complete! **-$50.00** has been transferred from account #13344 to
account #14232."

It commits with the negative value, which inverts the direction of the transfer.
The account the user picked as the destination gets debited, and the source gets
credited. Confirmed on the balances: 16008 went from $100.00 to $175.00 on the
equivalent Bill Pay case.

The transaction log keeps the negative verbatim:

```json
{"id":29683,"accountId":13899,"type":"Credit","amount":-50.00,"description":"Funds Transfer Received"}
```

A Credit row holding a negative amount contradicts itself, and will quietly break
anything downstream that sums by type: statements, running balances, reconciliation.

**Impact:** on its own this is bad. Combined with BUG-01 (no balance check) and
BUG-08 (no auth on the API), someone can pull an arbitrary amount out of an
account they don't own, with a single unauthenticated request.

**Severity:** High

**Screenshot:** [screenshots/fund-transfer/03-negative-amount-accepted.jpg](../screenshots/fund-transfer/03-negative-amount-accepted.jpg)
