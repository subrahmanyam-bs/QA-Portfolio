## Bug ID: BUG-11

**Title:** REST API returns the wrong status codes. 400 when a resource is missing, 500 when a required parameter is missing

**Module:** REST API (`/parabank/services/bank`)

**Environment:** curl on Windows 11, 2026-08-28. Contract: `/parabank/services/bank/openapi.json`, OpenAPI 3.0.1, "The ParaBank REST API" v3.0.0

**Steps to Reproduce:**

| # | Request | What it is |
|---|---------|-----------|
| 1 | `GET /accounts/99999999` | account that doesn't exist |
| 2 | `GET /customers/12323/accounts` | customer that doesn't exist |
| 3 | `GET /transactions/1` | transaction that doesn't exist |
| 4 | `POST /deposit?accountId=14787` | `amount` omitted, marked `required: true` in the spec |
| 5 | `POST /transfer?fromAccountId=13344&toAccountId=13899` | same, `amount` omitted |
| 6 | `POST /createAccount?customerId=12212&newAccountType=9&fromAccountId=13344` | enum value out of range |

**Expected Result:**
Steps 1-3 return `404 Not Found`. Steps 4-6 return `400 Bad Request` naming the
parameter that's wrong or missing.

**Actual Result:**

| # | Got | Body |
|---|-----|------|
| 1 | **400** | `Could not find account #99999999` |
| 2 | **400** | `Could not find customer #12323` |
| 3 | **400** | `Could not find transaction #1` |
| 4 | **500** | empty |
| 5 | **500** | empty |
| 6 | **500** | empty |

Two separate problems in here.

**Not found comes back as 400.** A client can't tell "your request was malformed"
apart from "the thing you asked for isn't there". Those need different handling,
and retry logic built on status codes will get it wrong.

**Bad or missing input comes back as 500 with an empty body.** Omitting a required
field is a client error. Surfacing it as an unhandled server exception gives the
caller nothing to work with, and tells you validation is escaping as an exception
instead of being checked before the work starts.

One more inconsistency worth noting: a non-numeric path segment
(`GET /accounts/abc`) returns **404** with an empty body, while a numeric but
unknown id returns **400**. The two are backwards relative to what the values
actually mean.

**Severity:** Medium

Nothing here loses data or money. It makes the API awkward to integrate against
and hides genuine faults in the 500 count.

**Screenshot:** None, API-level. Evidence is in
[api-testing/rest/rest-api-test-cases.md](../api-testing/rest/rest-api-test-cases.md),
cases TC-R06, R08, R11, R14, R16, R23 and R33.
