# Test Cases - Transfer Funds

**Module:** Transfer Funds
**URL:** https://parabank.parasoft.com/parabank/transfer.htm
**Executed:** 2026-08-28
**Preconditions:** Logged in as john/demo. Accounts 13344 (CHECKING, $4222.93) and 13899 / 14232 / 16119 (SAVINGS, $100.00 each).

The page is AJAX driven. TRANSFER posts to
`POST /parabank/services_proxy/bank/transfer?fromAccountId=&toAccountId=&amount=`
and swaps the form for a result panel without reloading. Worth knowing if you
automate this: there's no page navigation to wait on.

| TC ID | Scenario | Steps | Expected Result | Priority | Status |
|-------|----------|-------|-----------------|----------|--------|
| TC01 | Valid transfer between own accounts | 1. Open transfer.htm<br>2. Amount = `100`<br>3. From 13344, To 13899<br>4. TRANSFER | "Transfer Complete!" with "$100.00 has been transferred from account #13344 to account #13899." | High | Pass |
| TC02 | Balances update after transfer | 1. Note both balances in Accounts Overview<br>2. Run TC01<br>3. Reopen Accounts Overview | Source down exactly $100.00, destination up exactly $100.00 | High | Pass |
| TC03 | Zero amount | 1. Amount = `0`, From 13344, To 13899<br>2. TRANSFER | Rejected. Amount must be greater than zero | Medium | **Fail** - "Transfer Complete! $0.00 has been transferred", and a $0.00 transaction gets written ([BUG-03](../bug-reports/BUG-03.md)) |
| TC04 | Negative amount | 1. Amount = `-50`, From 13344, To 14232<br>2. TRANSFER | Rejected as invalid | High | **Fail** - "Transfer Complete! -$50.00 has been transferred". Money actually moves the other way, destination to source ([BUG-02](../bug-reports/BUG-02.md)) |
| TC05 | Amount over available balance | 1. From 13899 (holds $150.01)<br>2. Amount = `999999`, To 13344<br>3. TRANSFER | Rejected, insufficient funds. Balance must not go negative | High | **Fail** - goes through. 13899 ends at **-$999,848.99** ([BUG-01](../bug-reports/BUG-01.md)) |
| TC06 | Amount with 3 decimal places | 1. Amount = `100.999`, From 13344, To 13899<br>2. TRANSFER<br>3. Reopen Accounts Overview | Rejected, or rounded to 2dp before storing | High | **Fail** - accepted, and it permanently bricks both accounts. Every subsequent read returns HTTP 500 ([BUG-15](../bug-reports/BUG-15.md)) |
| TC07 | Non-numeric amount | 1. Amount = `abc`<br>2. TRANSFER | Field-level "enter a valid amount" message | Medium | Partial pass - rejected, but all you get is a bare "Error!" heading with no message ([BUG-04](../bug-reports/BUG-04.md)) |
| TC08 | Empty amount | 1. Leave Amount blank<br>2. TRANSFER | Rejected, "amount is required" | Medium | Partial pass - same bare "Error!" |
| TC09 | Source and destination are the same | 1. Amount = `25`, From 13344, To 13344<br>2. TRANSFER | Rejected. Self-transfer isn't a real operation | Medium | **Fail** - "Transfer Complete! $25.00 from account #13344 to account #13344", writes two offsetting rows ([BUG-03](../bug-reports/BUG-03.md)) |
| TC10 | Lower boundary, 1 cent | 1. Amount = `0.01`, From 13344, To 13899<br>2. TRANSFER | Accepted, exactly 1 cent moves | Medium | Pass |
| TC11 | Dropdown defaults | 1. Open transfer.htm<br>2. Read both dropdowns before touching anything | The two shouldn't default to the same account | Low | **Fail** - both default to 13344, so a straight submit is a self-transfer ([BUG-03](../bug-reports/BUG-03.md)) |
| TC12 | Result panel is unambiguous | 1. Run TC04<br>2. Read the whole right panel | One outcome panel only, success or error | Low | **Fail** - "Transfer Complete!" and an empty "Error!" heading render together ([BUG-04](../bug-reports/BUG-04.md)) |
| TC13 | Transfer shows in Account Activity | 1. Run TC01<br>2. Accounts Overview, click 13344 | "Funds Transfer Sent" debit of $100.00, and a matching "Funds Transfer Received" credit on 13899 | Medium | Pass |

## Summary

| Result | Count |
|--------|-------|
| Pass | 6 (2 of those partial) |
| Fail | 7 |
| **Total** | **13** |

Worst module in the project. Every amount validation you'd expect is missing:
sign, zero, scale, and available balance. TC06 is the one to look at first, it
destroys the account outright.

**Evidence:** `screenshots/fund-transfer/`
