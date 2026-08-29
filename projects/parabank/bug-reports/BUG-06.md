## Bug ID: BUG-06

**Title:** Bill Pay accepts a negative amount, which pays the customer instead of the payee

**Module:** Bill Pay

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Preconditions:** Logged in as john/demo. Account 16008 holds $100.00.

**Steps to Reproduce:**
1. Bill Pay
2. Payee: QA Water Board, 9 Utility Lane, Bengaluru, Karnataka, 560002, phone 9998887777
3. Account # `14565`, Verify Account # `14565`
4. Amount `-75`
5. From account # `16008`
6. SEND PAYMENT
7. Re-read the balance of 16008

**Expected Result:**
Amount field rejects negatives, the same way it already rejects letters.

**Actual Result:**
"Bill Payment Complete - Bill Payment to QA Water Board in the amount of
**$-75.00** from account 16008 was successful."

The direction of money flow inverts. 16008 goes **up**, $100.00 to $175.00. So a
customer can increase their own balance by paying a bill for a negative amount,
as many times as they like.

The detail that makes this a clear defect rather than a missing feature: the same
Amount field **does** validate. Type `abc` and you get "Please enter a valid
amount." So there's a validator on this field. It checks the type and never checks
the sign.

**Severity:** High

**Screenshot:** [screenshots/bill-pay/02-negative-amount-accepted.jpg](../screenshots/bill-pay/02-negative-amount-accepted.jpg)

**Related:** [BUG-02](BUG-02.md) is the same defect in Transfer Funds.
