# Login Module — Test Cases

**Application under test:** Demo_Merchant_Platform (fictional — see repository README)
**Module:** Authentication / Login
**Total test cases:** 23
**Requirement references:** R1–R11 in the repository README

> These test cases are designed but **not executed**. No results are claimed. Where a test case refers to evidence, it describes the evidence to capture during execution.

---

## Index

| ID | Test Scenario | Priority | Test Type |
|----|---------------|----------|-----------|
| TC_LOGIN_001 | Successful login with valid credentials | P1 | Functional |
| TC_LOGIN_002 | Email normalisation — case and surrounding whitespace | P2 | Functional |
| TC_LOGIN_003 | Password is treated as case-sensitive | P1 | Security |
| TC_LOGIN_004 | Email field format validation, including injection-style input | P2 | Validation |
| TC_LOGIN_005 | Password field required validation | P2 | Validation |
| TC_LOGIN_006 | Registered email with incorrect password | P1 | Negative |
| TC_LOGIN_007 | Unregistered email returns an identical generic error | P1 | Security |
| TC_LOGIN_008 | Login form usability and keyboard operation | P3 | Usability |
| TC_LOGIN_009 | Password masking and show/hide toggle | P2 | Security |
| TC_LOGIN_010 | Account lockout threshold — 4th vs 5th failed attempt | P1 | Boundary |
| TC_LOGIN_011 | Correct password rejected while the account is locked | P1 | Security |
| TC_LOGIN_012 | Failed attempt counter resets after a successful login | P2 | Functional |
| TC_LOGIN_013 | Account unlocks automatically after the lockout period | P2 | Boundary |
| TC_LOGIN_014 | Forgot password request returns a generic confirmation | P1 | Security |
| TC_LOGIN_015 | Password reset link can be used only once | P1 | Security |
| TC_LOGIN_016 | Password reset link expiry boundary | P2 | Boundary |
| TC_LOGIN_017 | Password complexity and length rules on the reset screen | P1 | Validation |
| TC_LOGIN_018 | Concurrent sessions on multiple devices | P2 | Session |
| TC_LOGIN_019 | Logout terminates the current session | P1 | Session |
| TC_LOGIN_020 | Browser back button does not expose protected data after logout | P1 | Session |
| TC_LOGIN_021 | Direct URL access to a protected page after logout | P1 | Session |
| TC_LOGIN_022 | An authentication credential captured before logout is rejected afterwards | P1 | Security |
| TC_LOGIN_023 | Idle session timeout | P1 | Session |

---

## TC_LOGIN_001 — Successful login with valid credentials

- **Test Scenario:** A registered merchant user with an active account signs in successfully and reaches the dashboard.
- **Preconditions:** An active user account exists. The user is not currently logged in. The account is not locked.
- **Test Steps:**
  1. Open the portal login page.
  2. Enter the registered email address in the Email field.
  3. Enter the correct password in the Password field.
  4. Click **Login**.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** The user is authenticated and redirected to the dashboard. The logged-in user's name or email is displayed in the header. A session is created. No error message is shown.
- **Priority:** P1
- **Test Type:** Functional (Positive)
- **Technique:** Equivalence Partitioning — valid credential class
- **Requirement:** R1

---

## TC_LOGIN_002 — Email normalisation: case and surrounding whitespace

- **Test Scenario:** The email field ignores letter case and surrounding whitespace, so a user who types their email in a different case or copy-pastes it with a trailing space can still sign in.
- **Preconditions:** The account `merchant.user@example.com` exists and is active.
- **Test Steps:**
  1. Open the login page.
  2. Enter the email in a different case with a leading and trailing space.
  3. Enter the correct password.
  4. Click **Login**.
  5. Log out and repeat with the variations listed in Test Data.
- **Test Data:**

  | Variation | Email entered |
  |-----------|---------------|
  | Upper case | `MERCHANT.USER@EXAMPLE.COM` |
  | Mixed case | `Merchant.User@Example.com` |
  | Leading space | `  merchant.user@example.com` |
  | Trailing space | `merchant.user@example.com  ` |

  Password `Sample@123` for all variations.
- **Expected Result:** Login succeeds for every variation. The email is normalised to lower case and trimmed before the account lookup. The account is not treated as unregistered, and no failed attempt is recorded against the account.
- **Priority:** P2
- **Test Type:** Functional / Validation
- **Technique:** Error Guessing — copy-paste and autocapitalise behaviour
- **Requirement:** R9

---

## TC_LOGIN_003 — Password is treated as case-sensitive

- **Test Scenario:** The password comparison is case-sensitive, so a password differing only in letter case is rejected. This confirms the password is not being lower-cased or normalised before comparison, which would weaken every account.
- **Preconditions:** An active account exists with password `Sample@123`.
- **Test Steps:**
  1. Open the login page.
  2. Enter the registered email address.
  3. Enter the password with altered letter case.
  4. Click **Login**.
- **Test Data:** Email `merchant.user@example.com` / Passwords `sample@123`, `SAMPLE@123`, `sAmple@123`
- **Expected Result:** Login fails for every variation with the generic error message. The failed attempt counter increases by one for each attempt. Access is never granted.
- **Priority:** P1
- **Test Type:** Security / Negative
- **Technique:** Error Guessing
- **Requirement:** R9

---

## TC_LOGIN_004 — Email field format validation, including injection-style input

- **Test Scenario:** The email field rejects malformed input at the client side and safely handles special characters and SQL-injection-style strings without an authentication bypass or a server error.
- **Preconditions:** The user is on the login page. A valid password is available so that only the email varies.
- **Test Steps:**
  1. Open the login page.
  2. Enter each value from the Test Data table in the Email field.
  3. Enter any password in the Password field.
  4. Click **Login** and record the response for each value.
- **Test Data:**

  | # | Email value | Class |
  |---|-------------|-------|
  | 1 | *(left blank)* | Empty |
  | 2 | `merchantuser` | Missing `@` and domain |
  | 3 | `merchant.user@` | Missing domain |
  | 4 | `merchant.user@example` | Missing top-level domain |
  | 5 | `@example.com` | Missing local part |
  | 6 | `merchant..user@example.com` | Consecutive dots |
  | 7 | `merchant user@example.com` | Space inside the address |
  | 8 | `' OR '1'='1` | Injection-style input |
  | 9 | `<script>alert(1)</script>` | Script-style input |
  | 10 | Local part of 255 characters | Excessive input length |

- **Expected Result:** Values 1–7 and 10 are blocked with a clear inline validation message such as "Enter a valid email address"; no authentication request is sent. Values 8 and 9 are also rejected as invalid email format. In no case is a user authenticated, and in no case is a database error, stack trace, or raw server error displayed. The script string is never executed or rendered as HTML in the error message.
- **Priority:** P2
- **Test Type:** Validation / Security
- **Technique:** Equivalence Partitioning across invalid email classes, plus basic injection input checks
- **Requirement:** R1
- **Design note:** Value 10 is an **excessive input length check, not a boundary value test.** A true boundary test needs a defined limit to sit either side of, and no requirement specifies the maximum length the email field accepts. RFC 5321 sets 64 characters for the local part and 254 for a complete address, but those are protocol limits rather than a product decision about this field. A 255-character local part is therefore clearly invalid input, which makes it a useful negative case, but it does not establish where this application's own limit sits. The missing field-length requirement is recorded as a gap in `test-scenarios/login-scenarios.md`. Once a limit is defined, this row would be replaced by three cases at limit − 1, limit and limit + 1.

---

## TC_LOGIN_005 — Password field required validation

- **Test Scenario:** Submitting the form without a password produces a field-level required message rather than a failed authentication attempt.
- **Preconditions:** The user is on the login page.
- **Test Steps:**
  1. Enter a valid registered email address.
  2. Leave the Password field empty.
  3. Click **Login**.
  4. Repeat with a password consisting only of spaces.
- **Test Data:** Email `merchant.user@example.com` / Password *(empty)*, then `"     "`
- **Expected Result:** An inline message such as "Password is required" is displayed below the Password field. The form is not submitted. Importantly, **no failed login attempt is recorded** against the account, so an empty submission cannot contribute to a lockout.
- **Priority:** P2
- **Test Type:** Validation
- **Technique:** Equivalence Partitioning — empty input class
- **Requirement:** R1, R3
- **Assumption:** No requirement explicitly states that a blocked client-side submission is excluded from the lockout count. This expected result is my assumption and would need confirmation from the product owner.

---

## TC_LOGIN_006 — Registered email with an incorrect password

- **Test Scenario:** A valid user entering a wrong password is denied access and shown a generic message that does not reveal which field was wrong.
- **Preconditions:** An active account exists. The failed attempt counter is 0.
- **Test Steps:**
  1. Open the login page.
  2. Enter the registered email address.
  3. Enter an incorrect password.
  4. Click **Login**.
  5. Note the exact wording of the error message.
- **Test Data:** Email `merchant.user@example.com` / Password `WrongPass@1`
- **Expected Result:** Login fails with the generic message "Invalid email or password". The message does not indicate that the password specifically was wrong. The email field retains the entered value; the password field is cleared. The failed attempt counter increases to 1.
- **Priority:** P1
- **Test Type:** Negative / Security
- **Technique:** Decision Table — valid email × invalid password × active account
- **Requirement:** R8

---

## TC_LOGIN_007 — Unregistered email returns an identical generic error

- **Test Scenario:** An attacker cannot discover which email addresses have accounts by comparing login responses. This is verified by comparing the message text and the HTTP status code against TC_LOGIN_006.
- **Preconditions:** The email `not.registered@example.com` has no account. TC_LOGIN_006 has been executed and its response recorded.
- **Test Steps:**
  1. Open browser DevTools and select the Network tab.
  2. Enter an unregistered email address and any password.
  3. Click **Login**.
  4. Record the on-screen message and the HTTP status code.
  5. Compare both against the values recorded in TC_LOGIN_006.
- **Test Data:** Email `not.registered@example.com` / Password `Sample@123`
- **Expected Result:** The on-screen message is character-for-character identical to TC_LOGIN_006 ("Invalid email or password"). The HTTP status code is identical. Nothing such as "User not found" or "Email not registered" is displayed.
- **Priority:** P1
- **Test Type:** Security
- **Technique:** Decision Table — invalid email × any password; user enumeration check
- **Requirement:** R8
- **Limitation:** Response times are also a potential enumeration channel, but a timing difference cannot be established reliably by manual observation in DevTools. It requires many repeated measurements and statistical comparison. This test therefore covers message text and status code only, and the timing channel is recorded as a gap in `test-scenarios/login-scenarios.md`.

---

## TC_LOGIN_008 — Login form usability and keyboard operation

- **Test Scenario:** The login form can be completed entirely from the keyboard and behaves the way users expect, without needing the mouse.
- **Preconditions:** The user is on the login page in a desktop browser.
- **Test Steps:**
  1. Load the login page and observe which field has focus.
  2. Type an email, press **Tab**, and observe where focus moves.
  3. Type a password and press **Enter** without clicking the button.
  4. Reload the page and press **Shift+Tab** from the Login button to check reverse order.
  5. Trigger a validation error, then correct the field and observe whether the error clears.
  6. Click **Login** and observe the button state while the request is in progress.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** Focus lands on the Email field on page load. Tab order is Email → Password → Show/Hide → Login → Forgot Password, with a visible focus indicator on each. Pressing Enter submits the form. Validation messages clear as soon as the field is corrected. The Login button shows a loading state and cannot be clicked twice while a request is in flight.
- **Priority:** P3
- **Test Type:** Usability / Accessibility
- **Technique:** Exploratory testing
- **Requirement:** Not specified — usability expectation, raised as an observation rather than a requirement failure

---

## TC_LOGIN_009 — Password masking and show/hide toggle

- **Test Scenario:** The password is hidden by default, can be revealed deliberately by the user, and is not exposed through the browser after use.
- **Preconditions:** The user is on the login page.
- **Test Steps:**
  1. Type a password into the Password field and observe the display.
  2. Inspect the field in DevTools and check the `type` attribute.
  3. Click the show/hide (eye) icon and observe the field.
  4. Click the icon again to hide it.
  5. Submit the form, then navigate back to the login page and check whether the password is restored by the back button.
- **Test Data:** Password `Sample@123`
- **Expected Result:** Characters are displayed as dots or asterisks by default and the input `type` is `password`. Clicking the icon reveals the plain text and switches the type to `text`; clicking again re-masks it. After submission and navigating back, the field is empty and the password does not appear in the page source or in the URL.
- **Priority:** P2
- **Test Type:** Security / UI
- **Technique:** Exploratory testing with DOM inspection
- **Requirement:** R1
- **Note:** Whether masked text can be copied to the clipboard is browser behaviour rather than application behaviour, so it is deliberately excluded from the expected result.

---

## TC_LOGIN_010 — Account lockout threshold: 4th vs 5th failed attempt

- **Test Scenario:** The account locks on exactly the fifth consecutive failed attempt — not earlier, not later. The boundary either side of the threshold is checked explicitly.
- **Preconditions:** An active account exists with a failed attempt counter of 0 and the account unlocked.
- **Test Steps:**
  1. Attempt login with the correct email and a wrong password four times in succession.
  2. After the 4th failure, attempt login with the **correct** password and confirm access is granted.
  3. Log out and reset the counter to 0 (re-run the precondition).
  4. Attempt login with a wrong password five times in succession.
  5. Observe the message shown on the 5th attempt.
  6. Attempt a 6th login with the correct password.
- **Test Data:** Email `merchant.user@example.com` / Wrong password `WrongPass@1` / Correct password `Sample@123`
- **Expected Result:** After 4 consecutive failures the account remains unlocked and the correct password grants access. After the 5th consecutive failure the account is locked and the message changes to state that the account is locked and for how long. The 6th attempt with the correct password is refused.
- **Priority:** P1
- **Test Type:** Boundary / Security
- **Technique:** Boundary Value Analysis on the attempt count (4, 5, 6) and State Transition
- **Requirement:** R3

---

## TC_LOGIN_011 — Correct password is rejected while the account is locked

- **Test Scenario:** Lockout is enforced regardless of credential correctness, and the lockout timer is not extended by further attempts.
- **Preconditions:** The account is locked following 5 consecutive failed attempts. The lock started less than 30 minutes ago.
- **Test Steps:**
  1. Enter the registered email and the **correct** password.
  2. Click **Login**.
  3. Repeat twice more with the correct password.
  4. Note the remaining lockout time communicated after each attempt.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** Every attempt is refused with the lockout message. Access is never granted during the lockout window. The remaining lockout period counts down from the original lock time and is **not** reset or extended by these attempts, so a locked-out genuine user is not held out indefinitely.
- **Priority:** P1
- **Test Type:** Security / State
- **Technique:** State Transition — locked state
- **Requirement:** R3

---

## TC_LOGIN_012 — Failed attempt counter resets after a successful login

- **Test Scenario:** A user who mistypes their password a few times and then signs in successfully does not carry the old failures forward into a later lockout.
- **Preconditions:** An active account with a failed attempt counter of 0.
- **Test Steps:**
  1. Attempt login with a wrong password three times.
  2. Log in successfully with the correct password.
  3. Log out.
  4. Attempt login with a wrong password twice more.
  5. Attempt login with the correct password.
- **Test Data:** Email `merchant.user@example.com` / Wrong password `WrongPass@1` / Correct password `Sample@123`
- **Expected Result:** Step 5 succeeds. The counter was reset to 0 at step 2, so the two failures at step 4 total 2, not 5, and the account is not locked. Backend check to perform: the failed attempt count for the user is 0 immediately after step 2.
- **Priority:** P2
- **Test Type:** Functional / State
- **Technique:** State Transition — counter reset path
- **Requirement:** R4

---

## TC_LOGIN_013 — Account unlocks automatically after the lockout period

- **Test Scenario:** A locked account becomes usable again after 30 minutes without administrator intervention, and not before.
- **Preconditions:** The account has just been locked. The exact lock time is recorded.
- **Test Steps:**
  1. Record the timestamp at which the account was locked.
  2. At lock time + 29 minutes, attempt login with the correct password.
  3. At lock time + 30 minutes, attempt login with the correct password.
  4. Verify the failed attempt counter after the successful login.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** The attempt at 29 minutes is refused with the lockout message. The attempt at 30 minutes succeeds and the user reaches the dashboard. The failed attempt counter is 0 after the successful login, so the user is not one mistake away from being locked out again.
- **Priority:** P2
- **Test Type:** Boundary / State
- **Technique:** Boundary Value Analysis on the lockout duration (29 min, 30 min)
- **Requirement:** R3, R4
- **Execution note:** Waiting 30 minutes of real time per run is not practical for repeated execution. In a real project this would be handled by shortening the lockout duration through environment configuration, or by adjusting the `locked_at` timestamp directly in the QA database. The 29/30 minute boundary would then be verified against the configured value rather than the production value.

---

## TC_LOGIN_014 — Forgot password request returns a generic confirmation

- **Test Scenario:** The forgot-password flow sends a reset link to a registered address but does not reveal whether an address is registered.
- **Preconditions:** `merchant.user@example.com` is registered; `not.registered@example.com` is not. Access to the registered mailbox is available.
- **Test Steps:**
  1. From the login page, click **Forgot Password**.
  2. Enter the registered email address and submit. Record the on-screen message.
  3. Check the mailbox for a reset email.
  4. Return to the forgot-password page, enter the unregistered address and submit.
  5. Compare the on-screen message with the one recorded in step 2.
- **Test Data:** `merchant.user@example.com`, `not.registered@example.com`
- **Expected Result:** Both submissions display the same generic confirmation, for example "If an account exists for this email address, a reset link has been sent." A reset email arrives only for the registered address. The reset link is a single-use URL containing a token, and the email does not contain the existing password.
- **Priority:** P1
- **Test Type:** Functional / Security
- **Technique:** Decision Table — registered × unregistered email; user enumeration check
- **Requirement:** R6, R8

---

## TC_LOGIN_015 — Password reset link can be used only once

- **Test Scenario:** A reset token is invalidated after it has been used, so an intercepted or forwarded link cannot be reused to take over the account.
- **Preconditions:** A valid, unused reset link has been received and is less than 15 minutes old.
- **Test Steps:**
  1. Open the reset link and set a new password successfully.
  2. Confirm login works with the new password, then log out.
  3. Open the **same** reset link again in the browser.
  4. Attempt to set another new password from that page.
- **Test Data:** New password `NewSample@456`, second attempt `Another@789`
- **Expected Result:** The first reset succeeds. On reopening the link, the page shows that the link is invalid or already used, and no password field is offered — or, if offered, the submission is rejected. The password remains `NewSample@456`. Backend check to perform: the reset token is marked as used.
- **Priority:** P1
- **Test Type:** Security
- **Technique:** Error Guessing — token reuse
- **Requirement:** R6

---

## TC_LOGIN_016 — Password reset link expiry boundary

- **Test Scenario:** A reset link stops working 15 minutes after it is issued, checked immediately either side of the boundary.
- **Preconditions:** Two fresh reset links have been requested, with their issue timestamps recorded. Neither has been used.
- **Test Steps:**
  1. Record the time at which each reset email was received.
  2. Open the first link at issue time + 14 minutes and set a new password.
  3. Request a fresh link and open it at issue time + 16 minutes.
  4. Attempt to set a new password from the expired link.
  5. Confirm the account password is unchanged after step 4.
- **Test Data:** New password `NewSample@456`
- **Expected Result:** The link opened at 14 minutes works and the password is changed. The link opened at 16 minutes shows an expired-link message with an option to request a new one, and the password is not changed. No stack trace or token value is displayed on the expiry page.
- **Priority:** P2
- **Test Type:** Boundary / Security
- **Technique:** Boundary Value Analysis on token lifetime
- **Requirement:** R6
- **Execution note:** As with TC_LOGIN_013, the boundary would be exercised by shortening the token lifetime through configuration or by adjusting `expires_at` in the QA database, rather than by waiting in real time on every run.

---

## TC_LOGIN_017 — Password complexity and length rules on the reset screen

- **Test Scenario:** The new-password field enforces the documented complexity and length rules, checked at the boundaries. Note that complexity is enforced here, at password set/reset, and deliberately **not** at login, where only a match is checked.
- **Preconditions:** A valid, unexpired reset link is open. The current password is `Sample@123`.
- **Test Steps:**
  1. Enter each value from the Test Data table into the New Password field.
  2. Enter the same value in the Confirm Password field.
  3. Submit and record the outcome for each value.
  4. After the first accepted value, confirm that the old password no longer works at login.
- **Test Data:**

  | # | Value | Length | Property | Expected |
  |---|-------|--------|----------|----------|
  | 1 | `Abc@123` | 7 | One below minimum | Rejected |
  | 2 | `Abcd@123` | 8 | Minimum | Accepted |
  | 3 | `Abcdefghijk@12345678` | 20 | Maximum | Accepted |
  | 4 | `Abcdefghijk@123456789` | 21 | One above maximum | Rejected |
  | 5 | `abcd@1234` | 9 | No uppercase | Rejected |
  | 6 | `Abcd@efgh` | 9 | No digit | Rejected |
  | 7 | `Abcd1234` | 8 | No special character | Rejected |
  | 8 | `Sample@123` | 10 | Same as current password | Rejected |
  | 9 | `Abcd@123` / confirm `Abcd@124` | 8 | Mismatched confirmation | Rejected |

- **Expected Result:** Values 2 and 3 are accepted. All others are rejected with a message that states the specific unmet rule. Where the field enforces a maximum length, value 4 cannot be typed beyond 20 characters. After a successful change, the old password `Sample@123` fails at login with the generic error and the new password succeeds.
- **Priority:** P1
- **Test Type:** Validation / Boundary
- **Technique:** Boundary Value Analysis on length (7, 8, 20, 21) and Equivalence Partitioning on character classes
- **Requirement:** R2, R10

---

## TC_LOGIN_018 — Concurrent sessions on multiple devices

- **Test Scenario:** The same user can be signed in on more than one device at the same time, and the sessions are independent of one another.
- **Preconditions:** An active account. Two separate browsers or profiles are available — for example Chrome and Firefox, or a normal and an incognito window — so that cookies are not shared.
- **Test Steps:**
  1. Log in as the user in Browser A and open the dashboard.
  2. Log in as the same user in Browser B.
  3. Refresh the dashboard in Browser A and confirm it is still usable.
  4. Perform an action in Browser B and confirm it succeeds.
  5. Log out in Browser B.
  6. Refresh the dashboard in Browser A.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** Both logins succeed. Logging in on Browser B does not terminate Browser A's session. After logging out of Browser B, Browser A remains logged in and functional, confirming the sessions are separate. Backend check to perform: two distinct active session records exist for the user during steps 2–5, and only one remains after step 5.
- **Priority:** P2
- **Test Type:** Session
- **Technique:** State Transition — parallel session states
- **Requirement:** R7

---

## TC_LOGIN_019 — Logout terminates the current session

- **Test Scenario:** Clicking Logout ends the session on the server and clears the session cookie in the browser, so the user is genuinely signed out rather than only appearing to be.
- **Preconditions:** The user is logged in and on the dashboard. DevTools is open on the Application and Network tabs.
- **Test Steps:**
  1. In DevTools → Application, identify where the authentication credential is held — cookie store, local storage or session storage — and note its name and value.
  2. Click **Logout**.
  3. Observe the page the user is returned to.
  4. Re-check the same location for the credential noted at step 1.
  5. Perform a backend check on the session record for this user, if the application maintains server-side sessions.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** The user is returned to the login page with a confirmation that they have been signed out. The credential is removed from the browser, or replaced with an expired value. Where server-side session records are used, the record for this session is marked inactive with a logout timestamp.
- **Priority:** P1
- **Test Type:** Session
- **Technique:** State Transition — logged in → logged out
- **Requirement:** R11
- **Design note:** This case covers the browser-side half of logout only. Removing the credential from the browser is necessary but not sufficient — TC_LOGIN_022 covers whether the server actually rejects it. The two are separated because a build can pass this one and fail that one, which is exactly the situation BUG_LOGIN_003 describes.
- **Evidence to capture during execution:** Screenshot of the credential store before and after logout; where applicable, the result of the active-session query in `sql-queries/validation-queries.sql` (query 7) taken after logout.

---

## TC_LOGIN_020 — Browser back button does not expose protected data after logout

- **Test Scenario:** After logout, pressing the browser Back button does not render a cached copy of the dashboard containing account data. This is a separate concern from session termination: the session can be correctly ended on the server while the browser still restores the page from its cache.
- **Preconditions:** The user was logged in, viewed the dashboard, and has just logged out. TC_LOGIN_019 is executed first, so that session termination itself is already understood before cache behaviour is examined.
- **Test Steps:**
  1. Press the browser **Back** button.
  2. Observe whether any account data is rendered, even briefly, before any redirect.
  3. Press **Back** again and then refresh the page.
  4. In DevTools → Network, inspect the response headers previously returned for the dashboard page.
- **Test Data:** Not applicable — navigation behaviour only
- **Expected Result:** The Back button does not display the dashboard with account data. The user is shown the login page. No account information appears even momentarily before a redirect. The dashboard response carries cache headers that prevent it being restored from the browser cache, such as `Cache-Control: no-store`.
- **Priority:** P1
- **Test Type:** Session / Security
- **Technique:** Error Guessing — cached page restore after logout
- **Requirement:** R11
- **Evidence to capture during execution:** Screen recording of the Back navigation, since a brief flash of cached data is easy to miss in a still screenshot; screenshot of the dashboard response headers.

---

## TC_LOGIN_021 — Direct URL access to a protected page after logout

- **Test Scenario:** A protected page cannot be reached by typing or pasting its URL after logout, for example from browser history or a bookmark.
- **Preconditions:** The user has logged out. The dashboard URL was copied while logged in.
- **Test Steps:**
  1. Paste the dashboard URL into the address bar and press Enter.
  2. Observe the result.
  3. Repeat using a bookmark created while logged in.
  4. Repeat in a new browser tab within the same browser session.
- **Test Data:** The dashboard URL captured before logout
- **Expected Result:** Every attempt redirects to the login page. No account data is rendered. After logging in again, the user is optionally returned to the originally requested page, which is acceptable behaviour, but access is never granted without authenticating.
- **Priority:** P1
- **Test Type:** Session / Security
- **Technique:** Error Guessing — deep link access without a session
- **Requirement:** R11
- **Evidence to capture during execution:** Screenshot of the redirect to the login page with the protected URL visible in the address bar history.

---

## TC_LOGIN_022 — An authentication credential captured before logout is rejected afterwards

- **Test Scenario:** Whatever credential the application uses to identify an authenticated request is rejected by the server once the user has logged out. This verifies that logout is enforced on the server and is not only a browser-side action of discarding the credential.
- **Preconditions:** The user is logged in. An API client such as Postman is available. TC_LOGIN_019 is executed first, so that browser-side logout behaviour is already understood.
- **Test Steps:**
  1. Open DevTools → Network and load the dashboard.
  2. Select the request that fetches the dashboard data and identify **which mechanism carries the authentication** — a session cookie, an `Authorization` header, a custom header, or another supported mechanism. Record what it is; the rest of the test uses that mechanism, whatever it turns out to be.
  3. Copy the complete request, including the credential identified in step 2, into the API client.
  4. Send the request while still logged in and confirm it returns account data. This establishes the baseline and proves the captured credential is genuinely the one being used.
  5. Return to the browser and click **Logout**.
  6. Send the identical request again from the API client, unchanged.
  7. Send it once more after a short interval.
- **Test Data:** The authenticated request captured at step 3, including whichever credential the application uses
- **Expected Result:** Step 4 succeeds and returns account data, confirming the captured request is valid. After logout, steps 6 and 7 are rejected — typically **401 Unauthorized**, or **403 Forbidden** depending on how the application distinguishes the two — and return no account data. The rejection happens because the server has invalidated the session, not because the credential has expired: it must be rejected regardless of its original expiry time. Repeating the request does not revive the session or extend its lifetime.
- **Priority:** P1
- **Test Type:** Security / Session
- **Technique:** Error Guessing — credential replay after logout
- **Requirement:** R11
- **Design note:** This test is written to be independent of the session mechanism. It does not assume bearer tokens, cookies, or a stateful server-side session, because R11 specifies the required behaviour and not the implementation. The tester identifies the mechanism at step 2 and the rest of the test follows from it, so the case stays valid if the implementation changes. What the application actually uses would be recorded in the execution notes.
- **Evidence to capture during execution:** API client responses for steps 4, 6 and 7 showing status code and body; a note of which credential mechanism was identified at step 2; result of the active-session query in `sql-queries/validation-queries.sql` (query 7) taken after logout, if the application uses server-side session records.

---

## TC_LOGIN_023 — Idle session timeout

- **Test Scenario:** A session left unattended expires after 15 minutes of inactivity, and activity within that window keeps it alive.
- **Preconditions:** The user is logged in on the dashboard.
- **Test Steps:**
  1. Log in and note the time.
  2. Leave the browser untouched for 14 minutes, then click a navigation link.
  3. Confirm the session is still active.
  4. Leave the browser untouched for a further 16 minutes without any interaction.
  5. Click a navigation link.
  6. Log in again and confirm access is restored.
- **Test Data:** Email `merchant.user@example.com` / Password `Sample@123`
- **Expected Result:** At step 2 the session is still valid and the page loads, confirming the timer measures idle time rather than total session age. At step 5 the user is redirected to the login page with a message indicating the session expired, and no account data is shown before the redirect. Logging in again creates a new session and works normally.
- **Priority:** P1
- **Test Type:** Session
- **Technique:** Boundary Value Analysis on the idle timeout (14 min, 16 min) and State Transition
- **Requirement:** R5
- **Execution note:** As with TC_LOGIN_013 and TC_LOGIN_016, the timeout would be shortened through environment configuration for repeated execution rather than waiting in real time, with the boundary checked against the configured value.

---

## Coverage map

Every area planned for this module, and the test cases that cover it. Several test cases intentionally cover more than one area rather than being duplicated, so a test case ID appears in more than one row here.

This is different from the **Test Type** column in the index above, which assigns each test case a single primary type. The index is used for counting; this map is used for checking coverage. A case such as TC_LOGIN_004 has a primary type of Validation but appears here under negative, validation, input validation and basic security.

| Area | Test cases |
|------|-----------|
| Positive functional | 001, 002 |
| Negative | 003, 004, 006, 007 |
| Boundary value | 010, 013, 016, 017 |
| Validation | 004, 005, 017 |
| Authentication | 001, 003, 006, 011 |
| Session management | 018, 019, 023 |
| Account lockout | 010, 011, 012, 013 |
| Password masking | 009 |
| Forgot password | 014, 015, 016, 017 |
| Multiple login attempts | 010, 012 |
| Multiple device login | 018 |
| Logout and session invalidation | 019, 022 |
| Browser back after logout | 020 |
| Direct URL access after logout | 021 |
| Authentication credential reuse after logout | 022 |
| Input validation | 004, 005 |
| Basic security | 003, 004, 007, 009, 011, 014, 015, 020, 021, 022 |
| Usability | 008, 009 |
