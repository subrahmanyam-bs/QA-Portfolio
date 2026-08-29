## Bug ID: BUG-14

**Title:** Admin Page is linked from every public page and opens without logging in

**Module:** Admin Page

**Environment:** parabank.parasoft.com, Chrome 141, Windows 11, 2026-08-28

**Preconditions:** Logged out, cookies cleared for parabank.parasoft.com.

**Steps to Reproduce:**
1. Open `https://parabank.parasoft.com/parabank/index.htm` without logging in
2. Look at the top navigation. "Admin Page" sits there next to Solutions, About
   Us, Services, Products and Locations
3. Click it, or go straight to `/parabank/admin.htm`

**Expected Result:**
An admin console isn't advertised in public navigation, and requesting it without
an authenticated admin session returns 401, 403, or a redirect to a login page.

**Actual Result:**
Page renders in full, controls all live. What's exposed:

- **Database**: INITIALIZE and CLEAN buttons, which reseed or wipe the entire database
- **JMS Service**: SHUTDOWN for the message listener
- **Data Access Mode**: flip the whole application between SOAP, REST (XML), REST (JSON) and JDBC
- **Web Service**: overwrite the SOAP and REST endpoint URLs the app calls out to
- **Application Settings**: initial balance, minimum balance, loan provider, loan processor, approval threshold

Any anonymous visitor can destroy all application data, or repoint the app's
service endpoints at a host of their choosing.

> **Is this really a bug?** Partly not. ParaBank is a deliberately imperfect
> training app, and this page is how testers reset it between runs, so it's
> intentional. I'm filing it at Low and calling it a documented characteristic of
> the demo rather than something to fix.
>
> It's in the report because on any real deployment it would be the single highest
> severity item in this whole project, and because it's directly relevant to
> anyone testing here: someone else hitting CLEAN mid-session will pull the data
> out from under your test run.

**Severity:** Low

**Screenshot:** [screenshots/admin/01-admin-page.jpg](../screenshots/admin/01-admin-page.jpg)
