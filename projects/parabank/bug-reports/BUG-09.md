## Bug ID: BUG-09

**Title:** Registration doesn't validate the format of SSN, Phone # or Zip Code, and treats whitespace as a filled-in field

**Module:** Registration

**Environment:** parabank.parasoft.com, Chrome 141 and curl, Windows 11, 2026-08-28

**Preconditions:** Logged out.

**Steps to Reproduce:**
Fill the registration form four times with a unique username each run. Everything
valid except the one field under test:

| Run | Field | Value sent |
|-----|-------|-----------|
| 1 | SSN | `abcdefghi` |
| 2 | Phone # | `not-a-phone` |
| 3 | Zip Code | `ABCDE!!` |
| 4 | First Name | three spaces |

Click REGISTER each time.

**Expected Result:**
1. SSN rejected unless it matches a 9-digit pattern
2. Phone # rejected unless it's a usable telephone number
3. Zip Code rejected unless it matches a postal code pattern
4. Whitespace trimmed before the required check runs, so run 4 gets "First name is
   required."

**Actual Result:**
All four register successfully. Each one returns "Your account was created
successfully. You are now logged in.", and the junk persists. The API reads it
straight back:

```json
{"firstName":"   ", ... ,"phoneNumber":"not-a-phone","ssn":"abcdefghi"}
```

Presence validation clearly exists, it fires on 10 of the 11 fields when you
submit empty. There's just no format or content check behind it. The result is
records that can't be used for what the fields are for: an account whose display
name renders blank, a phone number nobody can call, an SSN that isn't one.

Accounts this created, still on the sandbox: `neg_ssn_2608`, `neg_phone_2608`,
`neg_zip_2608`, `neg_ws_2608`.

**Severity:** Medium

**Screenshot:** [screenshots/registration/02-empty-form-validation.jpg](../screenshots/registration/02-empty-form-validation.jpg)
proves presence validation works.
[screenshots/registration/03-registration-success.jpg](../screenshots/registration/03-registration-success.jpg)
is the success page that came back for all four malformed submissions.
