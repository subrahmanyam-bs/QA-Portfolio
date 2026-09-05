# Database Testing - Medusa (PostgreSQL)

**Database access:** Available. A dedicated, isolated PostgreSQL 17.11 instance was provisioned for this project (port `5434`, database `medusa_qa`), separate from any other database on the machine.
**Schema inspected via:** `psql` (`\dt`, `\d <table>`), confirmed against `information_schema.tables`. **143 tables** exist in the `public` schema (real count, not estimated).
**Executed:** 2026-09-01 / 2026-09-02

All queries below are **read-only** (`SELECT`) except where explicitly noted, and were run directly against the live local database after exercising the corresponding API flows.

---

## Tables relevant to this project's scope

| Table | Relevant columns (verified via `\d`) |
|---|---|
| `product` | `id, title, handle, status, collection_id, discountable, deleted_at` |
| `customer` | `id, email, first_name, last_name, has_account, deleted_at, created_at` — unique index `IDX_customer_email_has_account_unique` on `(email, has_account)` |
| `cart` | `id, region_id, customer_id, email, currency_code, completed_at, deleted_at` |
| `cart_line_item` | line items belonging to a cart (referenced by `cart_id`) |
| `order` | `id, region_id, display_id (sequence), customer_id, status (enum), email, currency_code` |
| `order_cart` | join table linking a completed `order_id` back to its originating `cart_id` |

---

## Test Cases

| TC ID | Test Scenario | Query / Method | Expected Result | Status |
|---|---|---|---|---|
| DB-PROD-01 | No duplicate product handles exist | `SELECT handle, count(*) FROM product WHERE deleted_at IS NULL GROUP BY handle HAVING count(*) > 1;` | Zero rows returned | Pass — 0 rows |
| DB-PROD-02 | Seeded product count in the database matches what the Store API reports | `SELECT count(*) FROM product WHERE deleted_at IS NULL;` vs. `GET /store/products` → `count` | Both report `4` | Pass |
| DB-CART-01 | No orphaned cart line items (every `cart_line_item.cart_id` resolves to a real cart) | `SELECT count(*) FROM cart_line_item cli LEFT JOIN cart c ON c.id = cli.cart_id WHERE c.id IS NULL;` | `0` | Pass |
| DB-CART-02 | A cart created via the API is immediately visible in the database with the correct `region_id` and `currency_code` | Create a cart via `POST /store/carts`; `SELECT * FROM cart WHERE id = '<new_id>';` | Row exists, `currency_code = 'eur'`, `region_id` matches the Europe region | Pass |
| DB-CART-03 | Completing a cart sets `cart.completed_at` and links a `customer_id` | `SELECT id, customer_id, email, completed_at FROM cart WHERE id = 'cart_01M1ETJYQF7JQCJWYKTR7PDA75';` | `completed_at` is non-null; `customer_id` populated | Pass — `completed_at: 2026-09-01 21:26:56+05:30`, `customer_id: cus_01M1ETKJZ8JSS21SHV9D36K1A4` |
| DB-ORDER-01 | An order created from a cart correctly references that exact cart via `order_cart` | `SELECT * FROM order_cart WHERE order_id = 'order_01M1EV05DVMRATT14P97YMVSDH';` | Row exists; `cart_id` matches the cart used at checkout | Pass — `cart_id: cart_01M1ETJYQF7JQCJWYKTR7PDA75` (exact match) |
| DB-ORDER-02 | Order and cart agree on `customer_id` and `email` | `SELECT customer_id, email FROM "order" WHERE id = '...';` vs. the same columns on the linked `cart` row | Identical values on both rows | Pass — both `cus_01M1ETKJZ8JSS21SHV9D36K1A4` / `qa.tester+cart1@example.com` |
| DB-ORDER-03 | `order.display_id` is a sequential, auto-incrementing integer (not reused, not user-supplied) | `\d "order"` shows `display_id integer DEFAULT nextval('order_display_id_seq')` | Confirmed to be DB-sequence-generated, not client-controllable | Pass |
| DB-CUST-01 | A guest checkout email and a separately-registered customer account can coexist as two distinct rows differentiated by `has_account` | `SELECT id, email, has_account FROM customer WHERE email LIKE 'qa.%';` | Two rows: one `has_account = false` (guest), one `has_account = true` (registered), different emails/ids in this run, and the unique index is confirmed to be on `(email, has_account)` **not** `email` alone | Pass — confirms the schema explicitly allows this by design (see `\d customer` unique index) |
| DB-CUST-02 | Deleting (soft-delete) is used consistently, not hard deletes | `\d customer`, `\d product` both show a `deleted_at` column and a partial index `WHERE deleted_at IS NULL` | Confirmed on both tables inspected | Pass |
| DB-TX-01 | Cart total recalculation is transactionally consistent — no cart is ever left with a line item but a stale/zero total after an update | Re-fetch `cart` via API immediately after each line-item mutation during test execution (see `test-cases/carts/`) | Total always matches the sum of visible items | Pass (checked via API-observed state on every cart mutation performed in this project; no direct row-level lock/transaction inspection was performed) |
| DB-REGION-01 | Region and its countries are correctly related | `region` + `region_country` (queried via API, not raw SQL, since the Store API already exposes the full relation) | 7 countries returned for the "Europe" region, matching `GET /store/regions/{id}` | Pass |

## Proposed but not executed (labelled as such)
- **DB-PERF-01 (proposed):** Check index usage (`EXPLAIN ANALYZE`) on `product` search/filter queries under a catalog bigger than the 4-product default. Didn't run this, would need a much larger dataset than this project has.
- **DB-CONCURRENCY-01 (proposed):** Check for double-decrement of `inventory_level.reserved_quantity` under concurrent add-to-cart requests on the same variant. Would need a purpose-built concurrent load script, out of scope for a manual/API-first pass.

## Summary

| Result | Count |
|---|---|
| Pass | 10 |
| Proposed / Not Executed | 2 |
| **Total** | **12** |

Referential integrity between `cart`, `order`, `order_cart`, and `customer` checks out at the database level, matching exactly what the API reports. No discrepancies, no database-level defects.
