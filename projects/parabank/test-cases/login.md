# Test Cases - Login

**Module:** Customer Login
**URL:** https://parabank.parasoft.com/parabank/index.htm (the login panel sits on every public page)
**Form action:** `POST /parabank/login.htm`
**Executed:** 2026-08-28
**Test account:** john / demo (customer 12212)

| TC ID | Scenario | Steps | Expected Result | Priority | Status |
|-------|----------|-------|-----------------|----------|--------|
| TC01 | Valid credentials | 1. Open index.htm<br>2. Username `john`, Password `demo`<br>3. LOG IN | Redirect to overview.htm, header reads "Welcome John Smith", Accounts Overview table renders | High | Pass |
| TC02 | Right username, wrong password | 1. Username `john`, Password `wrongpass`<br>2. LOG IN | Refused with "The username and password could not be verified." | High | Pass |
| TC03 | Username that doesn't exist | 1. Username `nosuchuser999`, Password `demo`<br>2. LOG IN | Same generic message, no hint that the account doesn't exist | High | Pass |
| TC04 | Blank fields, all three combinations | 1. Both blank, then username only, then password only<br>2. LOG IN each time | "Please enter a username and password." in all three cases | High | Pass - consistent across all three |
| TC05 | Username is case sensitive | 1. Username `JOHN`, Password `demo`<br>2. LOG IN | Refused | Medium | Pass |
| TC06 | Password is case sensitive | 1. Username `john`, Password `DEMO`<br>2. LOG IN | Refused | Medium | Pass |
| TC07 | SQL injection in the credentials | 1. Username `' OR '1'='1`, Password `' OR '1'='1`<br>2. LOG IN | Auth is not bypassed | High | Pass, with a caveat. See the note below |
| TC08 | Hit a protected page with no session | 1. Fresh browser profile, no login<br>2. Go straight to overview.htm | Redirect to the login page with a "please log in" message | High | **Fail** - HTTP 500 and "An internal error has occurred and has been logged." ([BUG-10](../bug-reports/BUG-10.md)) |
| TC09 | Session dies on logout | 1. Log in as john<br>2. Log Out<br>3. Replay overview.htm with the same session cookie | Old session grants nothing, and the user lands back on the public home page | Medium | Pass - access is denied and logout does return you home. Denial uses the same 500 page as TC08 though |

## Summary

| Result | Count |
|--------|-------|
| Pass | 8 |
| Fail | 1 |
| **Total** | **9** |

Cleanest module in the project. Auth logic itself is solid: generic error
messages that don't leak whether an account exists, case sensitivity on both
fields, and sessions really are invalidated on logout.

The one failure isn't an auth hole. Access is correctly denied, it's just
reported as a server fault instead of a redirect.

## Note on TC07

The injection payload never reached the application. Cloudflare intercepted the
request and served a "Just a moment..." challenge page, so the result is
**not authenticated**, which is the outcome we want.

Be careful what you claim from that. It proves the edge blocked it. It says
nothing about whether the login query is parameterised underneath. Testing that
properly needs a payload that gets past the WAF, or direct access to a
non-fronted environment. Flagging it rather than recording a clean pass.
