# Test Summary Report - Medusa QA Portfolio Project

**Testing period:** 2026-09-01 to 2026-09-02
**Environment:** Local Medusa v2.19.0 instance (backend + admin, no local storefront), PostgreSQL 17.11, `http://localhost:9000`. Public Next.js Starter demo (`next.medusajs.com`) used for read-only UI observation only. Full details: `requirements/module-analysis.md`.

## Scope Tested
Authentication (admin + customer), Products, Carts, Customers, Regions, Orders. Direct Store API and Admin API testing, cross-checked against the PostgreSQL database. Full in/out-of-scope breakdown is in `test-plan/medusa-test-plan.md`.

## Test Case Totals

| Metric | Count |
|---|---|
| Total test cases designed | 83 |
| Executed (Pass + Fail) | 73 |
| Passed | 68 |
| Failed | 5 |
| Blocked | 5 |
| Not Executed | 5 |

(Breakdown by module/file is in `test-execution/execution-summary.md`.)

## Defects Found

| Bug ID | Title | Module | Severity | Priority |
|---|---|---|---|---|
| BUG-01 | Cart line-item quantity silently rounds non-integer values | Carts | Low | Medium |
| BUG-02 | Customer registration accepts a syntactically invalid email address | Authentication | Medium | Medium |
| BUG-03 | Negative `limit`/`offset` on product listing returns `500` instead of a validation error | Products | Medium | High |
| BUG-04 | `GET /store/orders/{id}` discloses full order details with no ownership check | Orders / Access Control | Medium | High |

### Severity distribution
| Severity | Count |
|---|---|
| Critical | 0 |
| High | 0 |
| Medium | 3 |
| Low | 1 |

No Critical or High-severity defects. The most consequential finding, BUG-04, is rated Medium specifically because its exploitability is limited by unguessable order IDs (full reasoning is in the bug report itself), though it's still High priority to fix given how cheap access-control checks are compared to what it costs to skip them.

## Major Observations

- **Auth and authorization hold up well**, except at one specific endpoint (BUG-04). No account enumeration on either login route, protected admin/customer routes correctly reject missing or invalid tokens, and the publishable-key gate on the Store API does exactly what it's documented to do.
- **Input validation is inconsistent.** Some fields get validated strictly (cart quantity bounds, invalid variant IDs, invalid resource IDs all return clean `4xx`), others aren't validated at all (registration email format), and one crashes instead of validating (pagination parameters). That unevenness, not any one specific missing check, is really the thread running through BUG-01, BUG-02, and BUG-03.
- **Financial and order data holds together.** Cart totals, checkout completion, and the resulting order all check out consistently at both the API layer and directly in the database (`order`, `order_cart`, `customer` tables). No discrepancies anywhere.
- **A small recurring pattern worth flagging once, not five times**: several validation failures come back as `401 Unauthorized` with a validation-style message (`"Password should be a string"`, for instance) instead of `400 Bad Request`. It shows up across a few different test cases; noted there each time but not logged as a separate bug each time, since the request is still correctly refused regardless.
- **Standing up the local environment was its own piece of work**, not just a formality before testing started. PostgreSQL and the Medusa scaffold needed real troubleshooting (a Windows-specific native-dependency install race condition, worked through and documented in `requirements/module-analysis.md` and `test-plan/medusa-test-plan.md` §11). Mentioning it here for transparency; it's not a Medusa defect.

## Risks
- Can't rule out UI-level issues (visual bugs, JS errors, layout problems) since no browser-based testing was possible here. Five test cases are explicitly Blocked for exactly this reason.
- Single-region, single-currency seed data means limited confidence in multi-region/multi-currency behavior specifically.
- How exploitable BUG-04 actually is in a real deployment depends on how order IDs might leak in practice (emails, logs, referrers). This project only looked at the underlying API behavior, not a specific production deployment's exposure.

## Recommendations
1. **BUG-04 first.** Add an object-level ownership check to `GET /store/orders/{id}`, either matching `customer_id` or requiring a scoped order-access token for guest orders, before this pattern gets relied on in a real storefront.
2. **BUG-03.** Validate `limit`/`offset` at the API boundary and reject negatives with a `400` before they ever reach the query builder. Cheap fix for what's currently an unhandled crash.
3. **BUG-02.** Add email format validation to registration. Basic input validation that's just missing from a field that doubles as the login identity.
4. **BUG-01.** Add integer-type validation on cart line-item `quantity` so a fractional value gets rejected instead of quietly rounded.
5. **Status codes on the auth routes** could use standardizing: `400` for request-shape problems, `401` reserved for actual auth failures. Not a functional bug, more of a "nice to have" for anyone building against this API.
6. **Worth a follow-up audit**: check other guest-accessible, ID-keyed Store API resources (payment collections, returns) for the same missing-ownership-check pattern found in BUG-04. Wouldn't be surprised if it's not isolated to orders.

## Release Assessment
Within what was actually tested here: no blocking Critical/High-severity functional defects turned up in the core commerce workflow, browse through cart through checkout through order. The four Medium/Low defects are real and worth fixing before shipping to production, BUG-04 especially, but none of them stop the core purchase flow from working end-to-end, which I verified directly. This assessment only covers what was in scope (`test-plan/medusa-test-plan.md` §3 has the full "Out of scope" list) — it says nothing about UI, non-test payment providers, load/performance, or multi-region behavior, since none of that was tested here.
