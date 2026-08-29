## Bug ID: BUG-10

**Title:** Hitting a protected page with no session returns HTTP 500 instead of sending you to the login page

**Module:** Session management / Login

**Environment:** parabank.parasoft.com, Chrome 141 and curl, Windows 11, 2026-08-28

**Preconditions:** A browser session with no ParaBank login.

**Steps to Reproduce:**

Never logged in:
1. Fresh browser profile, or clear cookies for parabank.parasoft.com
2. Go straight to `https://parabank.parasoft.com/parabank/overview.htm`

After logout:
3. Log in as john/demo
4. Log Out
5. Request overview.htm again with the same session cookie

**Expected Result:**
302 to the login page with something like "Please log in to continue." Access
denied cleanly, and the user gets an obvious next step. Applies to every protected
page: transfer.htm, billpay.htm, findtrans.htm, requestloan.htm, openaccount.htm,
updateprofile.htm.

**Actual Result:**
Both paths give HTTP 500 and the generic error page:

> **Error!**
> An internal error has occurred and has been logged.

```
curl -i https://parabank.parasoft.com/parabank/overview.htm
HTTP/1.1 500
<title>ParaBank | Error</title>
<p class="error">An internal error has occurred and has been logged.</p>
```

**To be clear about what this is and isn't.** Access *is* denied, and the session
*is* properly invalidated on logout. So it's not an authorisation hole and I'm not
filing it as one.

The problem is that an unauthenticated request is a completely normal thing to
happen, and it's being handled as a server fault. Three consequences: every
logged-out user following a bookmark gets counted as a 5xx in monitoring, real
server errors get buried in that noise, and the user is left on a dead end page
with no link to the login form.

**Severity:** Medium

**Screenshot:** [screenshots/login/03-unauthenticated-access-500.jpg](../screenshots/login/03-unauthenticated-access-500.jpg)
