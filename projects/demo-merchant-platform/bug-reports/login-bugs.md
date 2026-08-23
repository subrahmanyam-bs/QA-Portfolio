# Login Module — Defect Reports

**Application under test:** Demo_Merchant_Platform (fictional — see repository README)

> **These are illustrative defect reports.** Demo_Merchant_Platform does not exist and has not been tested. The purpose of this file is to demonstrate how a defect is analysed, described and prioritise[...]

The format follows a standard Jira defect layout. Environment and build values are placeholders showing what would be recorded, not a record of a real environment.

---

## BUG_LOGIN_001 — Failed login attempt counter is not reset after a successful login

| Field | Value |
|-------|-------|
| **Defect ID** | BUG_LOGIN_001 |
| **Module** | Authentication / Login |
| **Severity** | Major |
| **Priority** | P2 |
| **Status** | Illustrative example — not raised against a real system |
| **Reproducibility** | To be recorded during execution (attempts reproduced / attempts made) |
| **Build / Environment** | Placeholder: build number, environment name, operating system, browser and version |
| **Related test case** | TC_LOGIN_012 |
| **Related requirement** | R4 — a successful login resets the consecutive-failure counter to zero |

### Summary
The consecutive failed-attempt counter is not cleared when a user logs in successfully. Failures from earlier sessions accumulate, so a user is locked out after 5 failures spread across days rathe[...]

### Steps to reproduce
1. Log in as `merchant.user@example.com` and confirm the account is unlocked with a failure count of 0.
2. Log out.
3. Attempt to log in with an incorrect password three times.
4. Log in successfully with the correct password. The login succeeds.
5. Log out.
6. Attempt to log in with an incorrect password twice.
7. Attempt to log in with the correct password.

### Expected result
The successful login at step 4 resets the counter to 0. The two failures at step 6 bring the count to 2, which is below the threshold of 5, so the login at step 7 succeeds.

### Actual result
The login at step 7 is refused with the message *"Your account has been locked. Please try again after 30 minutes."* The counter was 3 after step 3, was not cleared by the successful login at step[...]

### Evidence to capture during execution
- Screenshot of the lockout message at step 7.
- Result of query 5 in `sql-queries/validation-queries.sql`, run immediately after step 4, showing whether the failed attempt count is 0 or still 3.

### Impact
Genuine users are locked out of their accounts without having failed five times in a row. Over time almost every user accumulates enough historical failures to trip the threshold on a single misty[...]

### Notes
The lockout trigger itself is unaffected — only the reset path. Because the counter also survives the 30-minute auto-unlock, an affected user is locked out again on their next single failure.

---

## BUG_LOGIN_002 — Email validation error is not cleared after the field is corrected

| Field | Value |
|-------|-------|
| **Defect ID** | BUG_LOGIN_002 |
| **Module** | Authentication / Login |
| **Severity** | Minor |
| **Priority** | P3 |
| **Status** | Illustrative example — not raised against a real system |
| **Reproducibility** | To be recorded during execution (attempts reproduced / attempts made) |
| **Build / Environment** | Placeholder: build number, environment name, browsers and screen resolutions tested |
| **Related test cases** | TC_LOGIN_004, TC_LOGIN_008 |
| **Related requirement** | R1 |

### Summary
Once the "Enter a valid email address" validation message is displayed, it remains on screen after the user corrects the email to a valid value. The message only disappears when the form is submit[...]

### Steps to reproduce
1. Open the login page.
2. Enter `merchantuser` in the Email field.
3. Move focus to the Password field. The message *"Enter a valid email address"* appears below the Email field.
4. Return to the Email field and correct the value to `merchant.user@example.com`.
5. Move focus to the Password field again.
6. Observe the area below the Email field.

### Expected result
The validation message clears as soon as the corrected value passes validation, and the error styling is removed from the field border.

### Actual result
The message and the error styling remain visible even though the email is now valid. They persist until the Login button is clicked. On a 1366×768 viewport the persistent message pushes the Login[...]

### Evidence to capture during execution
- Screenshot at 1920×1080 showing the message displayed while a valid email is in the field.
- Screenshot at 1366×768 showing the Login button pushed below the fold.

### Impact
Low functional impact — the user can still log in. The usability cost is that the screen contradicts itself, and on smaller laptop screens the persistent message hides the primary action. Users [...]

### Notes
The password required-field message behaves correctly and clears on correction, which points to the defect being specific to the email field's validation handler rather than to the validation fram[...]

---

## BUG_LOGIN_003 — Authentication credential remains accepted after logout

| Field | Value |
|-------|-------|
| **Defect ID** | BUG_LOGIN_003 |
| **Module** | Authentication / Session management |
| **Severity** | Critical |
| **Priority** | P1 |
| **Status** | Illustrative example — not raised against a real system |
| **Reproducibility** | To be recorded during execution (attempts reproduced / attempts made) |
| **Build / Environment** | Placeholder: build number, environment name, browser and API client versions |
| **Related test cases** | TC_LOGIN_022, TC_LOGIN_020 |
| **Related requirement** | R11 — after logout the server must invalidate the session so the associated credential is rejected for further authenticated requests |

### Summary
Logging out discards the authentication credential in the browser but does not invalidate the session on the server. A credential captured before logout continues to be accepted for authenticated[...]

### Steps to reproduce
1. Open the login page with DevTools on the Network tab.
2. Log in as `merchant.user@example.com`.
3. Open the dashboard and select the request that fetches the dashboard data.
4. Identify which mechanism carries the authentication on that request — session cookie, `Authorization` header, custom header or other — and record it. Copy the complete request, including t[...]
5. Send the copied request while still logged in and confirm it returns account data. This proves the captured credential is the one actually in use.
6. Return to the browser, click **Logout**, and confirm the browser discards the credential and returns to the login page.
7. Send the identical request again from the API client, unchanged.

### Expected result
After logout the server terminates the session. The request at step 7 is rejected — **401 Unauthorized** — and returns no account data, because a credential presented after logout must be rej[...]

### Actual result
The request at step 7 returns **200 OK** with the full dashboard payload, including the merchant name, account status and transaction summary. The credential continues to be accepted after logout[...]

### Evidence to capture during execution
- API client responses for steps 5 and 7, showing status code and body before and after logout.
- Which credential mechanism was identified at step 4, and whether the application maintains server-side session records.
- If server-side sessions are used, the result of query 7 in `sql-queries/validation-queries.sql`, run after logout, showing whether the session record is still marked active.
- How long the credential continues to be accepted after logout, measured rather than assumed.

### Impact
Anyone who obtains the credential — through a shared or public computer, a browser extension, a proxy, or logs that capture request headers — retains access to the account after the user has [...]

### Notes
The report deliberately describes the credential generically rather than naming a specific mechanism, because R11 states required behaviour and not implementation. The concrete mechanism observed[...]

A related symptom is covered by TC_LOGIN_020: if protected pages are served without `Cache-Control: no-store`, the browser Back button can briefly render the cached dashboard after logout. That s[...]
