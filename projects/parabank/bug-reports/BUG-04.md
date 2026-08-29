## Bug ID: BUG-04

**Title:** Transfer result panel shows success and an empty "Error!" heading at the same time, and bad input gives you no message at all

**Module:** Transfer Funds

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Preconditions:** Logged in as john/demo.

**Steps to Reproduce:**

Contradictory panel:
1. Transfer Funds, Amount = `-50`, From 13344, To 14232
2. TRANSFER
3. Read the whole right hand panel, not just the top of it

No message on bad input:
4. Reopen Transfer Funds, Amount = `abc`, TRANSFER
5. Repeat with Amount left blank

**Expected Result:**
One outcome panel, success or error, never both. Invalid or empty amount gets a
field-level message next to the input, which is exactly what Bill Pay already
does ("Please enter a valid amount.").

**Actual Result:**
Step 3 renders both panels stacked. "Transfer Complete!" with the confirmation
text, then an "Error!" heading underneath it with no error text under it. The
user has no way to tell whether their transfer happened.

Steps 4 and 5 hide the form entirely and render one word: **Error!** No message,
no field highlight, and no way back to the form except re-navigating to the page.

**Workaround for testers:** re-navigate to transfer.htm to get the form back. The
browser back button restores the page but leaves the previous panel state, which
is confusing when you're working through cases quickly.

**Severity:** Low

Cosmetic, no data impact. Worth fixing because Bill Pay handles the identical
scenario correctly, so this is an inconsistency inside one application rather than
a missing feature.

**Screenshot:** [screenshots/fund-transfer/03-negative-amount-accepted.jpg](../screenshots/fund-transfer/03-negative-amount-accepted.jpg),
showing "Transfer Complete!" with the stray "Error!" heading below it
