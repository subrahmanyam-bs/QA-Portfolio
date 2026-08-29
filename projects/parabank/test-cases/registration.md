# Test Cases - Registration

**Module:** Registration
**URL:** https://parabank.parasoft.com/parabank/register.htm
**Executed:** 2026-08-28
**Preconditions:** Logged out. 11 fields: First Name, Last Name, Address, City, State, Zip Code, Phone #, SSN, Username, Password, Confirm.

Validation is server side (Struts). The form posts, comes back, and renders the
errors inline. Nothing is checked in the browser.

| TC ID | Scenario | Steps | Expected Result | Priority | Status |
|-------|----------|-------|-----------------|----------|--------|
| TC01 | Register with valid data, then confirm auto-login | 1. Open register.htm<br>2. First = Pruthvi, Last = Tester, Address = 42 QA Street, City = Bengaluru, State = Karnataka, Zip = 560001, Phone = 9876543210, SSN = 123-45-6789<br>3. Username = qatester_2608, Password = Test@1234, Confirm = Test@1234<br>4. REGISTER | Account created. Page reads "Welcome qatester_2608 - Your account was created successfully. You are now logged in." Header shows "Welcome Pruthvi Tester" and the Account Services menu appears with no separate login | High | Pass |
| TC02 | Submit the form completely empty | 1. Open register.htm<br>2. REGISTER with nothing filled in | A "... is required." message against every mandatory field | High | Partial pass - fires for 10 of 11 fields. Phone # gets nothing ([BUG-13](../bug-reports/BUG-13.md)) |
| TC03 | Duplicate username | 1. Fill everything, Username = qatester_2608 (created in TC01)<br>2. REGISTER | Rejected with "This username already exists." | High | Pass |
| TC04 | Password and Confirm don't match | 1. Fill everything<br>2. Password = Test@1234, Confirm = Different@9<br>3. REGISTER | Rejected with "Passwords did not match." | High | Pass |
| TC05 | One mandatory field left out | 1. Fill everything except First Name<br>2. REGISTER | Rejected with "First name is required." | High | Pass |
| TC06 | SSN in a bad format | 1. Fill everything, SSN = `abcdefghi`<br>2. REGISTER | Rejected with an SSN format error | Medium | **Fail** - account created, SSN takes any text ([BUG-09](../bug-reports/BUG-09.md)) |
| TC07 | Phone number in a bad format | 1. Fill everything, Phone # = `not-a-phone`<br>2. REGISTER | Rejected with a phone format error | Medium | **Fail** - account created ([BUG-09](../bug-reports/BUG-09.md)) |
| TC08 | Zip code in a bad format | 1. Fill everything, Zip Code = `ABCDE!!`<br>2. REGISTER | Rejected with a zip format error | Medium | **Fail** - account created ([BUG-09](../bug-reports/BUG-09.md)) |
| TC09 | Whitespace only in a required field | 1. Fill everything, First Name = three spaces<br>2. REGISTER | Input should be trimmed before the required check, so expect "First name is required." | Medium | **Fail** - account created with a blank display name ([BUG-09](../bug-reports/BUG-09.md)) |
| TC10 | One character password, lower boundary | 1. Fill everything<br>2. Password = `1`, Confirm = `1`<br>3. REGISTER | Some minimum length or complexity rule rejects it | Low | **Fail** - account created ([BUG-13](../bug-reports/BUG-13.md)) |
| TC11 | Reflected XSS probe | 1. First Name = `<img src=x onerror=alert(1)>`<br>2. Use an existing username so the form re-renders with an error instead of creating a record<br>3. REGISTER, then inspect the response HTML | Payload isn't echoed back unescaped and doesn't execute | High | Pass - the value isn't reflected in the response at all |

## Summary

| Result | Count |
|--------|-------|
| Pass | 6 (1 partial) |
| Fail | 5 |
| **Total** | **11** |

The pattern here: presence validation exists and works, format validation doesn't
exist at all. Four of the five failures are the same missing check applied to
different fields.

TC11 was run against a duplicate username on purpose, so the probe wouldn't leave
another junk account behind.

**Evidence:** `screenshots/registration/`
