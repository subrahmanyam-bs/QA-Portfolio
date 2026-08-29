## Bug ID: BUG-08

**Title:** REST and SOAP APIs have no authentication at all. Any customer's SSN, address and balances are readable, and money can be moved between accounts, with zero credentials

**Module:** REST API (`/parabank/services/bank`) and SOAP API (`/parabank/services/ParaBank`)

**Environment:** curl on Windows 11, 2026-08-28. No cookie, no header, no token sent on any request below. Reproducible from a clean shell.

**Steps to Reproduce:**

1. Read a customer, sending nothing:
   ```
   GET https://parabank.parasoft.com/parabank/services/bank/customers/12212
   ```
2. Change the id and read a different one, e.g. `17762`.
3. Read that customer's accounts and balances:
   ```
   GET https://parabank.parasoft.com/parabank/services/bank/customers/17762/accounts
   ```
4. Move money out of one customer's account into another customer's account,
   still unauthenticated:
   ```
   POST https://parabank.parasoft.com/parabank/services/bank/transfer?fromAccountId=13344&toAccountId=23112&amount=1
   ```
5. Look at how login itself works:
   ```
   GET https://parabank.parasoft.com/parabank/services/bank/login/john/demo
   ```

**Expected Result:**
Every one of these returns 401. A customer resource is readable only by an
authenticated session that owns it. A transfer only happens between accounts
belonging to the authenticated customer. Credentials never go in a URL path, and
the SSN never appears in a response body.

**Actual Result:**
All five return 200 with no credentials whatsoever.

Step 1 hands over the customer's full identity:
```json
{"id":12212,"firstName":"John","lastName":"Smith",
 "address":{"street":"1431 Main St","city":"Beverly Hills","state":"CA","zipCode":"90210"},
 "phoneNumber":"310-447-4121","ssn":"622-11-9999"}
```

Step 3 hands over someone else's balances:
```json
[{"id":23112,"customerId":17762,"type":"CHECKING","balance":550.50}]
```

Step 4 returns `Successfully transferred $1 from account #13344 to account #23112`.

Customer ids are sequential integers. So the whole customer base, names,
addresses, phone numbers and Social Security Numbers, comes out by incrementing
one path parameter in a loop. Nothing rate limits it.

Step 5 puts the password in the URL **path**, where it gets written in clear text
to proxy logs, server access logs and browser history.

SOAP behaves identically. The `login` operation over `/services/ParaBank` returns
the same `<ssn>` element and needs no WS-Security header.

**Severity:** High

I'd argue Critical on a real system, since this is unauthenticated bulk PII
disclosure plus unauthenticated funds movement. Capping at High to stay inside the
severity scale used across this project.

**Suggested fix direction:** token or session auth on every service endpoint,
ownership checks on `customerId` and `accountId` path parameters, move login to
`POST` with credentials in the body, and drop `ssn` from all response DTOs.

**Screenshot:** None. This is an API-level finding and the request/response pairs
above are the evidence. Corresponding test cases are TC-R09, TC-R09b and TC-R34 in
[api-testing/rest/rest-api-test-cases.md](../api-testing/rest/rest-api-test-cases.md).
