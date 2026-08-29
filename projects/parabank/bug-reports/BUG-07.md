## Bug ID: BUG-07

**Title:** Bill Pay accepts a zero-amount payment and calls it successful

**Module:** Bill Pay

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Steps to Reproduce:**
1. Log in as john/demo, go to Bill Pay
2. Payee: QA Water, 9 Utility Lane, Bengaluru, Karnataka, 560002, phone 9998887777
3. Account # `14565`, Verify Account # `14565`
4. Amount `0`
5. Any From account
6. SEND PAYMENT

**Expected Result:**
Rejected, amount must be greater than zero. The field already produces "The
amount cannot be empty." when blank, so a companion minimum-value rule is the
obvious expectation.

**Actual Result:**
"Bill Payment Complete - Bill Payment to QA Water in the amount of $0.00 from
account 14787 was successful."

A $0.00 debit gets written to the account history. Repeat it a few times and
Account Activity, plus anything generated from it, fills with rows that represent
nothing.

**Severity:** Medium

No money moves, so this sits below the negative-amount case. It's a data quality
problem rather than a financial one.

**Screenshot:** [screenshots/bill-pay/01-bill-payment-success.jpg](../screenshots/bill-pay/01-bill-payment-success.jpg),
same confirmation panel with $0.00 in place of the amount

**Related:** [BUG-03](BUG-03.md), same gap in Transfer Funds.
