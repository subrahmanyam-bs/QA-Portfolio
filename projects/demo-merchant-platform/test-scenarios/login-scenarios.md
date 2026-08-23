# Login Module — Test Scenarios

**Application under test:** Demo_Merchant_Platform (fictional — see repository README)

A test scenario states *what* needs to be verified and *why it matters*. The detailed steps live in `test-cases/login/login-test-cases.md`. Scenarios are listed first because they are how coverage gaps get found — it is much easier to notice a missing scenario than a missing test case.

> These scenarios are designed but not executed. No results are claimed.

---

## How these scenarios were identified

| Source | What it produced |
|--------|-----------------|
| Documented requirements R1–R11 | The baseline functional scenarios |
| Risk analysis | Scenarios where failure causes account takeover or lockout of genuine users |
| Technique-driven design | Boundary and state transition scenarios around lockout, session and token expiry |
| Exploratory testing | Usability, keyboard and browser-behaviour scenarios not stated in any requirement |

---

## Scenarios

| # | Scenario | Risk if it fails | Test cases |
|---|----------|------------------|-----------|
| SC_LOGIN_01 | Verify a registered user with an active account can sign in | Nobody can use the product | TC_LOGIN_001 |
| SC_LOGIN_02 | Verify email input is normalised for case and whitespace | Genuine users are wrongly told their account does not exist | TC_LOGIN_002 |
| SC_LOGIN_03 | Verify password comparison is case-sensitive | Password strength is silently reduced for every account | TC_LOGIN_003 |
| SC_LOGIN_04 | Verify email format validation and safe handling of special characters | Malformed data reaches the backend; injection risk | TC_LOGIN_004 |
| SC_LOGIN_05 | Verify required-field handling on an empty submission | Empty submissions count towards lockout and lock out genuine users | TC_LOGIN_005 |
| SC_LOGIN_06 | Verify access is denied for a wrong password | Unauthorised access | TC_LOGIN_006 |
| SC_LOGIN_07 | Verify registered and unregistered emails are indistinguishable in the response | Attackers can build a list of valid accounts to target | TC_LOGIN_007 |
| SC_LOGIN_08 | Verify the form is fully operable from the keyboard | Poor usability; accessibility barrier for keyboard-only users | TC_LOGIN_008 |
| SC_LOGIN_09 | Verify the password is masked and not exposed via the browser | Shoulder-surfing and credential exposure in the DOM | TC_LOGIN_009 |
| SC_LOGIN_10 | Verify the account locks on exactly the 5th consecutive failure | Brute-force attacks succeed, or genuine users are locked out too early | TC_LOGIN_010 |
| SC_LOGIN_11 | Verify lockout is enforced even for the correct password | The lockout control can be bypassed | TC_LOGIN_011 |
| SC_LOGIN_12 | Verify the failed attempt counter resets after a successful login | Users are locked out because of old, unrelated mistakes | TC_LOGIN_012 |
| SC_LOGIN_13 | Verify the account unlocks automatically after 30 minutes | Support load from manual unlocks; users blocked indefinitely | TC_LOGIN_013 |
| SC_LOGIN_14 | Verify the forgot-password request does not reveal whether an account exists | User enumeration through a second channel | TC_LOGIN_014 |
| SC_LOGIN_15 | Verify a reset link cannot be used a second time | A forwarded or intercepted link allows account takeover | TC_LOGIN_015 |
| SC_LOGIN_16 | Verify a reset link expires after 15 minutes | An old email in a compromised mailbox stays usable indefinitely | TC_LOGIN_016 |
| SC_LOGIN_17 | Verify password rules are enforced when a new password is set | Weak passwords enter the system | TC_LOGIN_017 |
| SC_LOGIN_18 | Verify concurrent sessions on multiple devices behave independently | Users are unexpectedly signed out; or stale sessions survive | TC_LOGIN_018 |
| SC_LOGIN_19 | Verify logout terminates the session on the server, not only in the browser | Logout gives users a false sense of security | TC_LOGIN_019 |
| SC_LOGIN_20 | Verify the browser back button cannot restore a cached protected page after logout | Account data is visible on a shared or public computer after logout | TC_LOGIN_020 |
| SC_LOGIN_21 | Verify a protected URL cannot be reached directly after logout | Bookmarks and history become a way back into the account | TC_LOGIN_021 |
| SC_LOGIN_22 | Verify an authentication credential captured before logout is rejected afterwards | A captured credential keeps working after the user believes they signed out | TC_LOGIN_022 |
| SC_LOGIN_23 | Verify an idle session expires after 15 minutes | An unattended machine leaves an account open | TC_LOGIN_023 |

Scenarios SC_LOGIN_19 to SC_LOGIN_22 deliberately separate four behaviours that are often bundled into a single "logout works" check. They can fail independently: a server can correctly terminate a session while the browser still restores the page from cache, and a page can redirect correctly in the browser while the underlying API still accepts the old token.

---

## Scenarios identified but not covered in version 1

These are recorded deliberately. Leaving them undocumented would look like the risk was never considered; recording them shows the analysis was done and the scope was a decision.

| Scenario | Why it is not covered yet |
|----------|--------------------------|
| Response-time based user enumeration | A timing difference cannot be established reliably by manual observation. It requires repeated measurement and statistical comparison, which is an automation task rather than a manual one. Noted as a limitation in TC_LOGIN_007. |
| Rate limiting by IP address in addition to per-account lockout | Not in the documented requirements for v1 |
| CAPTCHA after repeated failures | Feature not present in the fictional application |
| Two-factor authentication | Feature not present in v1 |
| Single sign-on / social login | Feature not present in v1 |
| Boundary testing of the email field length | No requirement defines the maximum length the field accepts, so there is no limit to test either side of. TC_LOGIN_004 covers excessive input as a negative case only. Once a limit is defined, cases at limit − 1, limit and limit + 1 would be added. |
| Session behaviour when the password is changed while another device is logged in | Not specified in R6, R7 or R11; a requirement clarification would be needed first |
| Paste behaviour in the password field | Browser-dependent; worth checking but not specified as a requirement |
| Behaviour when the network drops mid-login | Not specified; would need a requirement on retry and duplicate submission |
| Login on mobile browsers and small viewports | Planned for a later version alongside responsive UI testing |
| Cross-browser execution matrix | Planned for a later version |
| Password history — preventing reuse of the last N passwords | R10 only requires the new password to differ from the current one; no history depth is specified |
| Localisation and right-to-left layouts | Application is English-only in v1 |
| Performance under concurrent login load | Out of scope for a manual functional portfolio of the Demo Merchant Platform |
