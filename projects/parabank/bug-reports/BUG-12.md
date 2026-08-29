## Bug ID: BUG-12

**Title:** createAccount reports a balance of 0 for an account that really opens with $100, and creates an account even when the required newAccountType is missing

**Module:** REST API, `POST /parabank/services/bank/createAccount`

**Environment:** curl on Windows 11, 2026-08-28

**Preconditions:** Customer 12212 (john), funding account 13344.

**Steps to Reproduce:**

Wrong response payload:
1. Note the balance of 13344
2. `POST /createAccount?customerId=12212&newAccountType=1&fromAccountId=13344`
3. Read the response body
4. Wait a few seconds, then `GET /accounts/{newId}`
5. Re-read 13344

Required parameter not enforced:
6. `POST /createAccount?customerId=12212&fromAccountId=13344`, leaving out
   `newAccountType`, which the OpenAPI document marks `required: true`

**Expected Result:**
Step 3 returns the account as it actually stands, `"balance": 100.00`, matching
the rule printed on openaccount.htm: "A minimum of $100.00 must be deposited into
this account at time of opening."
Step 6 returns 400 naming the missing parameter.

**Actual Result:**

Step 3 gives 200 with a balance of **0**:
```json
{"id":33324,"customerId":12212,"type":"SAVINGS","balance":0}
```

Step 5 shows 13344 **was** debited $100.00, and step 4 shows the new account
**does** hold $100.00:
```json
{"id":33324,"customerId":12212,"type":"SAVINGS","balance":100.00}
```

So the money is fine. The response body is what's wrong. It gets serialised
before the opening deposit is applied, so every API client is told the new account
is empty. Anything that trusts the response, to show a balance or decide whether
the account still needs funding, acts on stale data.

Step 6 gives 200 and creates the account anyway, silently defaulting to CHECKING:
```json
{"id":31326,"customerId":12212,"type":"CHECKING","balance":0}
```

A parameter the published contract marks required isn't enforced, so a caller
with a malformed request gets the wrong account type instead of an error.

> **Note on how this was diagnosed.** First pass I read the `balance: 0` response
> alongside the debited funding account and wrote this up as money vanishing,
> $100 leaving the source and never arriving. Re-reading the account a few seconds
> later showed 100.00 and disproved that. Worth the extra check: the two versions
> of this report have very different severities.

The UI path is correct end to end. openaccount.htm debits $100.00 and immediately
shows the new account holding $100.00. Only the API response is affected.

**Severity:** Medium

**Screenshot:** [screenshots/open-account/01-account-opened-ui.jpg](../screenshots/open-account/01-account-opened-ui.jpg),
the UI path working properly, for comparison
