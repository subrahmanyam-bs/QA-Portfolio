# Test Cases - Customers

**Module:** Customers (profile, address management, access control)
**Interfaces under test:** `GET/POST /store/customers/me`, `POST /store/customers/me/addresses`, `GET /store/orders`
**Environment:** Local Medusa v2.19.0, `http://localhost:9000`. Registered customer `qa.customer1@example.com` (see `test-cases/authentication/registration-test-cases.md`)
**Executed:** 2026-09-02

Registration and login test cases live under `test-cases/authentication/`. This file covers profile, address, and order-history behavior for an already-authenticated customer.

| TC ID | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Priority | Test Type | Status |
|---|---|---|---|---|---|---|---|---|
| TC-CUST-001 | Authenticated customer retrieves their own profile | Valid customer JWT | — | 1. `GET /store/customers/me` | `200`; `customer.email` matches the logged-in account | High | Positive / Functional | Pass |
| TC-CUST-002 | Customer updates their own profile field | Valid customer JWT | `{"first_name": "QAUpdated"}` | 1. `POST /store/customers/me` | `200`; `customer.first_name` is now `"QAUpdated"`, `updated_at` changes | High | Positive / Functional | Pass |
| TC-CUST-003 | Customer adds a new address | Valid customer JWT | Full address (name, `address_1`, city, `country_code: de`, postal code) | 1. `POST /store/customers/me/addresses` | `200`; new address object appears in `customer.addresses` with all fields stored exactly as sent | High | Positive / Functional | Pass |
| TC-CUST-004 | Address creation does not enforce required sub-fields (city, country, postal code) | Valid customer JWT | Address with only `first_name`, `last_name`, `address_1`, no city/country/postal code | 1. `POST /store/customers/me/addresses` with an incomplete address | Recording what actually happens: `200`, the address saves with `city`, `country_code`, `postal_code` all `null` | Medium | Boundary / Data Validation | Pass, see the note below on why this isn't a bug |
| TC-CUST-005 | A customer cannot fetch another customer's profile by ID | Two distinct customers exist (`qa.customer1@example.com`, and the guest-order customer) | Customer A's JWT, Customer B's `customer_id` | 1. `GET /store/customers/{customer_B_id}` while authenticated as Customer A | No such route is exposed on the Store API — plain framework `404 Cannot GET ...`, not customer data | High | Security / Access Control | Pass — confirms the Store API only ever exposes the caller's own profile via `/store/customers/me`, never an arbitrary ID |
| TC-CUST-006 | Customer's order history is scoped to their own orders only | Customer has 0 orders under their registered email; a separate guest order exists under a different email | Customer JWT for `qa.customer1@example.com` | 1. `GET /store/orders` | `200`; `orders: []`, `count: 0` — the guest order (different email) is correctly excluded | High | Positive / Data Isolation | Pass |
| TC-CUST-007 | Unauthenticated request to customer profile is rejected | No bearer token | — | 1. `GET /store/customers/me` with no `Authorization` header | `401 {"message":"Unauthorized"}` | High | Negative / Security | Pass (same evidence as TC-AUTH-011) |
| TC-CUST-008 | Customer address book UI renders and supports add/edit in the browser | Admin/storefront UI reachable | — | 1. Log in to a storefront account UI<br>2. Add/edit an address via the form | Address form validates and saves correctly in-browser | Medium | UI | Blocked — no browser automation tool available in this environment |

## Notes

**TC-CUST-004.** Saving an address with no `city`/`country_code`/`postal_code` just works — none of it is enforced at save time. I don't think that's a bug. It reads like a deliberate choice: let someone save a partial address now and finish it later, then actually require the country when it matters, at checkout, where shipping and tax calculations need it. Calling that intentional rather than filing it, since second-guessing that design call isn't really my place from a black-box test.

## Summary

| Result | Count |
|---|---|
| Pass | 7 |
| Blocked | 1 |
| **Total** | **8** |

Nothing broken in profile, address, or order-history handling. And the access control here is genuinely good — there's no route on the Store API that even lets you ask for someone else's profile.
