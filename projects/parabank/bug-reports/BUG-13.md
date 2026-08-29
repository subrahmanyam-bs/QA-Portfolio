## Bug ID: BUG-13

**Title:** Registration has no password rules at all, and doesn't require Phone # even though Bill Pay does

**Module:** Registration

**Environment:** parabank.parasoft.com, Chrome 141 and curl, Windows 11, 2026-08-28

Two findings on the same form.

### Part 1 - no password policy

1. Open register.htm, fill every field with valid data
2. Password = `1`, Confirm = `1`
3. REGISTER

Expected a minimum length or complexity rejection. A banking app taking a
one-character password isn't defensible.

Got: "Your account was created successfully. You are now logged in." The account
`neg_weakpw_2608` exists with the password `1`. No minimum length, no complexity
rule, no strength indicator, no feedback of any kind.

### Part 2 - Phone # required in one module, optional in another

4. Open register.htm and click REGISTER on a completely empty form
5. Read which fields get flagged
6. For comparison, open billpay.htm and click SEND PAYMENT on an empty form

Registration flags 10 of 11 fields: First Name, Last Name, Address, City, State,
Zip Code, SSN, Username, Password, Confirm. **Phone # gets nothing**, and its
label carries no "optional" marker either.

Bill Pay, on its own payee phone field, flags "Phone number is required."

So the same data point is mandatory in one place and silently optional in
another, with nothing on screen telling the user which rule is in force where.

**Expected Result:**
Part 1, rejected with a minimum length message. Part 2, Phone # is either required
everywhere or labelled optional where it isn't, and the two modules agree.

**Severity:** Low

Part 1 would be higher on a real product. On a public demo with no real accounts
behind it, it's a policy gap rather than an exploitable one.

**Screenshot:** [screenshots/registration/02-empty-form-validation.jpg](../screenshots/registration/02-empty-form-validation.jpg),
every field flagged except Phone #
