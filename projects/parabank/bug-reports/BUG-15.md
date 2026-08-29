## Bug ID: BUG-15

**Title:** Transfer accepts an amount with 3 decimal places and permanently corrupts both accounts, which can never be read again

**Module:** Transfer Funds (UI and REST API)

**Environment:** parabank.parasoft.com, Chrome 141 / curl, Windows 11, 2026-08-28

**Preconditions:** Logged in as john/demo. Accounts 13344 and 13899 both healthy and readable.

**Steps to Reproduce:**
1. Transfer `100.999` from 13344 to 13899. Either path works:
   - UI: Transfer Funds, type `100.999` in Amount, click TRANSFER
   - API: `POST /services/bank/transfer?fromAccountId=13344&toAccountId=13899&amount=100.999`
2. Read either account back: `GET /services/bank/accounts/13344`
3. Open Accounts Overview in the UI.

**Expected Result:**
Amount is rejected, or rounded to 2 decimal places before being stored. Currency
can't hold a tenth of a cent.

**Actual Result:**
Step 1 succeeds. Response is `Successfully transferred $100.999 from account
#13344 to account #13899`.

After that both accounts are dead. Every read returns HTTP 500:

```
GET /services/bank/accounts/13344   -> 500
GET /services/bank/accounts/13899   -> 500
GET /services/bank/customers/12212/accounts -> 500
```

Accounts Overview returns 500 too, so the customer can no longer see any of their
accounts, including the 9 that are undamaged.

**Root cause is visible in the SOAP fault.** The REST layer swallows it and
returns an empty 500, but SOAP surfaces the exception:

```xml
<faultstring>Rounding necessary</faultstring>
```

That's `java.lang.ArithmeticException: Rounding necessary`, thrown by
`BigDecimal.setScale(2)` called with no `RoundingMode`. The write path stores 3
decimals happily. The read path can't scale that back to 2 without being told how
to round, so it throws, every time, forever.

**This is not recoverable through the application.** I tried:

| Repair attempt | Result |
|---|---|
| Compensating transfer of `0.001` back | 500 |
| `POST /deposit?accountId=13344&amount=0.001` | 500 |
| `POST /withdraw?accountId=13344&amount=0.001` | 500 |
| SOAP `getAccount` | `Rounding necessary` fault |

Every write operation reads the account first, so nothing can touch a corrupted
row. The only fix is Admin Page -> INITIALIZE, which reseeds the whole database.

**Scope check.** Only the two accounts in the transfer are affected. The other 9
accounts on the same customer still return 200, which rules out a general outage:

```
13344 -> 500    (in the transfer)
13899 -> 500    (in the transfer)
14232, 14565, 14787, 15675, 15897, 16008, 16119, 33102, 33324 -> all 200
```

**Severity:** High

Any user can permanently destroy their own account access by typing one extra
digit. No confirmation, no warning, no way back. On a real system this is a
support ticket that needs DBA intervention.

**Screenshot:** No screenshot. Reproduced at the service layer, and the UI just
shows the generic error page already captured in
[screenshots/login/03-unauthenticated-access-500.jpg](../screenshots/login/03-unauthenticated-access-500.jpg).
The request/response pairs above are the evidence.

**Related:** the missing validation is the same family as
[BUG-02](BUG-02.md) (no sign check) and [BUG-03](BUG-03.md) (no zero check). The
amount field is not validated for sign, for zero, or for scale.
