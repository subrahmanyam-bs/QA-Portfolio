# Medusa - Module Analysis

This document captures what was actually verified about the application under test before test design began. Only observed, reproduced facts are recorded here. Anything not directly checked is marked accordingly rather than assumed.

---

## 1. Application Overview

[Medusa](https://medusajs.com) is an open-source, headless commerce platform (Node.js/TypeScript backend + PostgreSQL) used to build storefronts, marketplaces, and B2B commerce applications. It exposes a **Store API** (customer-facing: products, carts, checkout, customer accounts) and an **Admin API** (merchant-facing: catalog, orders, customers, settings), plus an Admin dashboard UI built on top of the Admin API.

### Why this application was chosen
Medusa is a real, production-grade e-commerce backend, not a single-page demo app. It has a genuine multi-module domain: catalog, pricing, cart, checkout, orders, regions/currency, customers. That's enough surface area to run functional, API, and database testing together against one coherent workflow: browse, cart, checkout, order.

---

## 2. Environment

There's no public Medusa sandbox out there with an exposed Store/Admin API and publishable key (checked this properly, see Section 8), so a local environment was set up specifically for this project.

| Parameter | Value | Verification |
|---|---|---|
| **Application** | Medusa v2.19.0 (`@medusajs/medusa`) | Verified — from installed `package.json` |
| **Backend/API base URL** | `http://localhost:9000` | Verified — reachable, `GET /health` returns `200 OK` |
| **Admin dashboard URL** | `http://localhost:9000/app` | Verified — returns `200 OK`, serves the Medusa Admin SPA |
| **Environment type** | Local development instance, provisioned for this project | Verified |
| **Node.js version** | v24.12.0 | Verified (`node -v`) |
| **Package manager** | npm 11.6.2 | Verified |
| **Database** | PostgreSQL 17.11, running as a dedicated local instance on port `5434` (isolated from any other database on the machine), database name `medusa_qa` | Verified (`psql`, `SELECT version()`) |
| **OS** | Windows 11 | Verified |
| **Redis** | Not installed / not configured. Medusa falls back to its in-memory event bus and locking module ("Local Event Bus installed. This is not recommended for production.") | Verified from server startup logs |
| **Scaffolding tool** | `create-medusa-app@2.19.0` (official Medusa installer), backend + admin only, no Next.js storefront installed locally | Verified |

### Frontend / Storefront
No storefront was installed in the local environment (see Section 9, "Known limitations"). For storefront-style, customer-facing UI observation, the **official public Medusa Next.js Starter demo** was used:

| Parameter | Value | Verification |
|---|---|---|
| **Public storefront URL** | `https://next.medusajs.com/us` | Verified reachable, `200 OK`, real product/category/cart UI renders |
| **Nature of this environment** | Official Medusa-maintained demo of the Next.js Starter Template, backed by a private Medusa backend not under this project's control | Verified — no publishable API key, backend URL, or API access is exposed anywhere in the page, its client JS bundles, or the starter's own GitHub repository/README |
| **Consequence for scope** | This storefront is usable for **read-only, black-box UI observation** (browsing, layout, navigation) but **not** for API-level or authenticated checkout testing, since no credentials to its backend exist or can legitimately be obtained | Verified by investigation, see Section 8 |

---

## 3. Authentication

| Aspect | Detail | Verification |
|---|---|---|
| **Admin auth endpoint** | `POST /auth/user/emailpass` → returns a JWT bearer token | Verified |
| **Customer auth endpoint** | `POST /auth/customer/emailpass` (login), `POST /auth/customer/emailpass/register` (registration) → JWT bearer token | Verified |
| **Admin API authorization** | `Authorization: Bearer <token>` required on all `/admin/*` routes; omitting it returns `401 {"message":"Unauthorized"}` | Verified |
| **Store API authorization (app identification)** | All `/store/*` routes require an `x-publishable-api-key` header identifying the sales channel; omitting or sending an invalid key returns `400` with a clear error message | Verified |
| **Store API authorization (customer identity)** | Customer-scoped store routes (e.g. `POST /store/customers`) additionally require `Authorization: Bearer <customer JWT>` | Verified |
| **Session mechanism** | Stateless JWT bearer tokens (no server-side session store observed); cookie-based session auth is documented by Medusa as an alternative but was not exercised in this project | Verified (JWT) / Not Executed (cookie flow) |
| **Password policy** | No client-visible minimum-length or complexity enforcement was observed during registration testing | Verified (absence, for the inputs tried — see `test-cases/authentication/`) |

---

## 4. Test Accounts

No passwords or tokens are recorded in this repository or in Git history.

| Account | Purpose | Notes |
|---|---|---|
| `qa.admin@medusa-qa.local` | Admin dashboard / Admin API testing | Created via `medusa user` CLI on the local instance. Password held locally only, outside this repository. |
| `qa.customer1@example.com` | Registered storefront customer, used for customer/cart/order test cases | Created via `POST /auth/customer/emailpass/register` during this project. Password held locally only. |
| `qa.tester+cart1@example.com` | Guest checkout email (no account) | Used to complete a guest order; Medusa auto-creates a `customer` row with `has_account = false` for this email (verified at the database level). |

`api-testing/postman/medusa-api-collection.json` uses Postman **environment variables** (`base_url`, `access_token`, `publishable_api_key`, etc.) for all credentials — no secret values are committed.

---

## 5. Major Business Modules (as installed)

Confirmed by direct API exploration (`/store/*`, `/admin/*`) and by inspecting the PostgreSQL schema (143 tables in `public`):

| Module | Confirmed via | Notes |
|---|---|---|
| **Product catalog** | `GET /store/products`, `\d product` | 4 seeded products (Medusa Shorts, T-Shirt, Sweatpants, Sweatshirt), each with multiple variants (e.g. sizes S/M/L/XL) and SKUs |
| **Pricing** | `calculated_price` on variants and shipping options | Prices are region/currency-scoped; `region_id` must be supplied as a query parameter to calculate a price (see Section 8, finding #1) |
| **Cart** | `POST /store/carts`, `.../line-items`, `.../shipping-methods` | Full cart lifecycle exercised: create → add item → set address → add shipping method |
| **Customer** | `POST /auth/customer/emailpass/register`, `POST /store/customers` | Registration is a two-step flow: create an auth identity, then create the customer profile linked to it |
| **Region / Currency** | `GET /store/regions` | 1 seeded region ("Europe", currency `eur`, countries `dk, fr, de, it, es, se, gb`) |
| **Checkout (Payment Collections)** | `POST /store/payment-collections`, `.../payment-sessions` | Only `pp_system_default` (manual/test) payment provider is configured — no real payment gateway in this environment |
| **Fulfillment / Shipping** | `GET /store/shipping-options` | 2 seeded shipping options ("Standard Shipping", "Express Shipping"), both flat-rate, provider `manual_manual` |
| **Orders** | `POST /store/carts/{id}/complete`, `GET /admin/orders` | A cart was completed end-to-end into a real order (`display_id: 1`); order fields `status`, `payment_status`, `fulfillment_status` are tracked independently |
| **Admin dashboard** | `GET /app` | Reachable, but I didn't get to click through it properly. No browser tool in this environment (Section 9 has the full list of what that ruled out) |

### Verified workflow: Guest checkout (cart → order)
1. `POST /store/carts` with a `region_id` → cart created in EUR.
2. `POST /store/carts/{id}/line-items` with a `variant_id` and `quantity` → item added, cart totals recalculated.
3. `POST /store/carts/{id}` with `email`, `shipping_address`, `billing_address`.
4. `POST /store/carts/{id}/shipping-methods` with a shipping `option_id` → shipping added to cart total.
5. `POST /store/payment-collections` with the `cart_id`, then `POST /store/payment-collections/{id}/payment-sessions` with `provider_id: pp_system_default`.
6. `POST /store/carts/{id}/complete` → returns `{"type":"order", "order": {...}}`.

Ran this exact sequence and it produced order `display_id: 1`, total `€30` (2 × €10 item + €10 shipping), `payment_status: authorized`, `fulfillment_status: not_fulfilled`. Checked it against the database afterward too (`order`, `order_cart`, `customer` tables, see `database-testing/database-test-cases.md`) and it's consistent.

---

## 6. Dependencies

- PostgreSQL has to be reachable at the configured `DATABASE_URL` or the backend won't start at all. That's a hard dependency by design; I didn't separately fault-inject it (pull the DB out mid-run) for this project.
- Redis is an optional dependency; without it, Medusa substitutes in-memory modules and logs an explicit warning that this is unsuitable for production. This is a **known constraint of the test environment**, not a defect.
- A publishable API key (scoped to a sales channel) is a hard prerequisite for any `/store/*` call.

---

## 7. Known Limitations of This Test Environment

- **No local storefront UI.** The Next.js Starter Storefront wasn't installed locally, mainly a time-and-resources call: the full install (backend + admin + storefront together) kept hitting native-dependency crashes on this Windows machine (see the test plan's risk section for the details), and a backend-only install got a working environment up much faster. So storefront-style UI testing here is either (a) read-only observation against the public `next.medusajs.com` demo, or (b) exercised at the API level directly against the local backend. Option (b) is functionally equivalent for business-logic verification, it just doesn't confirm the rendered UI actually behaves the same way.
- **No browser automation tool was on hand** either, so no click-through testing or screenshots of the Admin dashboard or a storefront happened. Anything that needs a browser to verify (password masking, that kind of thing) is marked **Blocked**, not silently skipped.
- **No real payment gateway.** Only Medusa's manual/system-default payment provider is configured, so payment-provider-specific behavior (e.g. Stripe 3-D Secure, card decline handling) is out of scope and was not tested.
- **Single region/currency seeded.** Only "Europe" (EUR) exists in this environment; multi-region/multi-currency comparison testing is limited to what a second, manually-created region would show, and is noted in test cases as environment-dependent where relevant.
- **Single-tenant, local instance.** No worrying about other testers' data messing with results, the way you'd have to on a shared public demo. Trade-off is there's no large catalog to throw at pagination/search either. It's the 4-product Medusa default seed, full stop.

---

## 8. Investigation Notes (Environment Selection)

Before provisioning a local backend, the following was checked and is recorded here because it shaped the project's scope:

1. `https://next.medusajs.com/us` is the official public demo, and it's live and browsable, but its backend host, publishable API key, and API contract aren't exposed anywhere: not in the rendered page, not in the Next.js client bundles, not in the `medusajs/nextjs-starter-medusa` README. That README actually says outright that the storefront needs the user's own Medusa backend on port 9000 — it was never meant to be a shared public sandbox. So this one's a dead end for API testing.
2. `https://admin-demo.medusajs.site` turned up referenced in the storefront's HTML. Chased it down and it's just another copy of the same Next.js storefront app (redirects by locale to `/dk/...`), not a raw Admin/Store API host.
3. So a local Medusa instance was the only real option for genuine API and database access. That meant installing PostgreSQL locally, and I set up a dedicated, isolated Postgres cluster on port `5434` for this project rather than reusing anything already on the machine.

### Verified API behavior worth flagging early (informs test design)
- `region_id` needs to be a **query parameter**, not a header, when asking for a calculated price on `GET /store/products`. Send it as `x-region-id` and it's silently ignored, then the request fails with `"Missing required pricing context to calculate prices - region_id"`. Cost me a few minutes the first time.
- Two real defects turned up even during this early exploration, before formal test-case execution started, and both are logged under `bug-reports/`: `BUG-01` (non-integer cart quantity gets silently rounded) and `BUG-02` (registration accepts a garbage, non-email string as the email).

---

## 9. Items Requiring Further Verification

- Cookie-based Store API session auth. Medusa documents it as an alternative to JWT; didn't get to it.
- Admin dashboard interactive/visual behavior. Blocked, no browser tool on hand.
- Behavior with a second region/currency configured. Would mean more environment setup than this round called for.
- Rate limiting or lockout on failed logins. Didn't hit either way in the number of attempts made here, so I can't say it's present or absent, just that it wasn't tested.
