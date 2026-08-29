## Bug ID: BUG-05

**Title:** Bill Pay lets you pay more than the account holds

**Module:** Bill Pay

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Preconditions:** Logged in as john/demo. Account 16119 holds $100.00.

**Steps to Reproduce:**
1. Bill Pay
2. Payee: QA Water, 9 Utility Lane, Bengaluru, Karnataka, 560002, phone 9998887777
3. Account # `14565`, Verify Account # `14565`
4. Amount `500000`
5. From account # `16119`, which holds $100.00
6. SEND PAYMENT
7. Check the balance of 16119

**Expected Result:**
Rejected, insufficient funds. Nothing moves, 16119 stays at $100.00.

**Actual Result:**
"Bill Payment Complete - Bill Payment to QA Water in the amount of $500,000.00
from account 16119 was successful."

Committed. 16119 drops to **-$499,900.00**:

```
GET /parabank/services/bank/accounts/16119
{"id":16119,"customerId":12212,"type":"SAVINGS","balance":-499900.00}
```

**Severity:** High

Same missing balance check as [BUG-01](BUG-01.md), found through a different
entry point. Filed separately because it's a separate user-facing flow that needs
its own regression test, but a single fix in the service layer should close both.

**Screenshot:** [screenshots/bill-pay/01-bill-payment-success.jpg](../screenshots/bill-pay/01-bill-payment-success.jpg)
for the confirmation panel format. Balance evidence is the API call above.
