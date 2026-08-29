## Bug ID: BUG-03

**Title:** Transfer accepts a zero amount, and lets you transfer an account to itself, which is also what the dropdowns default to

**Module:** Transfer Funds

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

Two related problems, both on the same form. Filing together because they share a
cause: nothing validates the combination of inputs before the transfer is built.

### Part 1 - zero amount

1. Transfer Funds
2. Amount = `0`, From 13344, To 13899
3. TRANSFER

Expected rejection. Got "Transfer Complete! $0.00 has been transferred from
account #13344 to account #13899", plus a $0.00 debit and a $0.00 credit written
to history. Account Activity fills up with rows that mean nothing.

### Part 2 - same account both sides

4. Reopen Transfer Funds and look at the two dropdowns **before touching anything**
5. Amount = `25`, leave both dropdowns alone
6. TRANSFER

Both dropdowns default to the same account, 13344. So a user who types an amount
and clicks TRANSFER, which is the obvious thing to do, performs a self-transfer.

Result: "Transfer Complete! $25.00 has been transferred from account #13344 to
account #13344", and two offsetting transactions land on one account.

**Expected Result:** zero is rejected. The To dropdown defaults to something other
than the From account, and picking the same account on both sides is rejected.

**Severity:** Medium

Neither one loses money, which is why this isn't High. But part 2 is reachable by
accident on the default form state, and both dirty the transaction history in a
way that's tedious to unpick later.

**Screenshot:** [screenshots/fund-transfer/01-transfer-form.jpg](../screenshots/fund-transfer/01-transfer-form.jpg)
(both dropdowns on 13344) and
[screenshots/fund-transfer/02-transfer-success.jpg](../screenshots/fund-transfer/02-transfer-success.jpg)
