-- ============================================================================
-- Backend validation queries — Login module
-- Application under test: Demo_Merchant_Platform (fictional)
--
-- Purpose: verify at the database level what the user interface reports, so
--          that a test result is confirmed by the stored data and not only by
--          what appears on screen.
--
-- SQL DIALECT
--   These queries are written for PostgreSQL. They use PostgreSQL date and
--   interval syntax and assume boolean columns. They are not portable as
--   written; on MySQL the interval arithmetic would use DATE_SUB() and
--   TIMESTAMPDIFF(), and the boolean columns would be 0 / 1.
--
-- STATUS
--   Not executed. Demo_Merchant_Platform does not exist and there is no database
--   behind these queries. They are included to demonstrate how backend
--   validation would be designed alongside the test cases, and are referenced
--   from the test cases and defect reports as checks to perform during
--   execution.
--
-- NOTES
--   * Table and column names are generic examples, not any real schema.
--   * SELECT statements only. Nothing here modifies or deletes data, so these
--     queries would be safe to run against a shared QA database.
--   * Email addresses use the reserved example.com domain.
--
-- ASSUMED SCHEMA
--   users           (user_id, email, full_name, account_status, is_locked,
--                    locked_at, failed_attempt_count, last_login_at, created_at)
--   login_attempts  (attempt_id, user_id, email_entered, attempt_time,
--                    is_successful, ip_address)
--   user_sessions   (session_id, user_id, created_at, last_activity_at,
--                    expires_at, is_active, logged_out_at)
--   password_resets (reset_id, user_id, reset_token, created_at, expires_at,
--                    is_used, used_at)
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. User existence
--    Supports: TC_LOGIN_001, TC_LOGIN_007
--    Confirms the account under test exists before running a positive case,
--    and confirms the negative-case address genuinely has no account.
-- ----------------------------------------------------------------------------
SELECT user_id,
       email,
       account_status,
       created_at
FROM   users
WHERE  LOWER(email) = LOWER('merchant.user@example.com');

-- Confirm the unregistered address used in the enumeration test has no row.
-- A count of 0 is the expected outcome.
SELECT COUNT(*) AS matching_accounts
FROM   users
WHERE  LOWER(email) = LOWER('not.registered@example.com');


-- ----------------------------------------------------------------------------
-- 2. Email normalisation check
--    Supports: TC_LOGIN_002
--    Detects accounts stored with mixed case or with surrounding whitespace,
--    which is the usual root cause of "my email is not recognised" reports.
-- ----------------------------------------------------------------------------
SELECT user_id,
       email,
       CASE WHEN email <> LOWER(email) THEN 'Not lower case' ELSE 'OK' END AS case_check,
       CASE WHEN email <> TRIM(email)  THEN 'Has whitespace' ELSE 'OK' END AS whitespace_check
FROM   users
WHERE  email <> LOWER(email)
   OR  email <> TRIM(email);


-- ----------------------------------------------------------------------------
-- 3. Account status
--    Supports: TC_LOGIN_001, TC_LOGIN_010, TC_LOGIN_011
--    Establishes the precondition state: is the account active, and is it
--    currently locked. Preconditions that are only assumed rather than
--    verified are a common cause of a false test failure.
-- ----------------------------------------------------------------------------
SELECT user_id,
       email,
       account_status,
       is_locked,
       locked_at,
       failed_attempt_count
FROM   users
WHERE  LOWER(email) = LOWER('merchant.user@example.com');


-- ----------------------------------------------------------------------------
-- 4. Last login timestamp
--    Supports: TC_LOGIN_001
--    Verifies a successful login actually updated last_login_at, rather than
--    the interface simply redirecting to the dashboard.
-- ----------------------------------------------------------------------------
SELECT user_id,
       email,
       last_login_at,
       ROUND(EXTRACT(EPOCH FROM (NOW() - last_login_at)) / 60) AS minutes_since_last_login
FROM   users
WHERE  LOWER(email) = LOWER('merchant.user@example.com');


-- ----------------------------------------------------------------------------
-- 5. Failed login attempts — current counter
--    Supports: TC_LOGIN_010, TC_LOGIN_012, and BUG_LOGIN_001
--    To be run immediately after a successful login. Per requirement R4 the
--    count must be 0. A non-zero value here is the evidence to attach to
--    BUG_LOGIN_001.
-- ----------------------------------------------------------------------------
SELECT user_id,
       email,
       failed_attempt_count,
       is_locked,
       locked_at
FROM   users
WHERE  LOWER(email) = LOWER('merchant.user@example.com');


-- ----------------------------------------------------------------------------
-- 6. Failed login attempts — audit trail
--    Supports: TC_LOGIN_010, TC_LOGIN_012
--    Shows the actual sequence of attempts, which is how a counter that
--    disagrees with the audit trail gets spotted. Also confirms that blocked
--    empty form submissions (TC_LOGIN_005) were not recorded as failed
--    attempts.
-- ----------------------------------------------------------------------------
SELECT attempt_id,
       email_entered,
       attempt_time,
       is_successful,
       ip_address
FROM   login_attempts
WHERE  LOWER(email_entered) = LOWER('merchant.user@example.com')
  AND  attempt_time >= NOW() - INTERVAL '1 hour'
ORDER BY attempt_time DESC;

-- Count only the consecutive failures since the most recent success. This is
-- the number that should be compared against the lockout threshold of 5.
SELECT COUNT(*) AS failures_since_last_success
FROM   login_attempts
WHERE  LOWER(email_entered) = LOWER('merchant.user@example.com')
  AND  is_successful = FALSE
  AND  attempt_time > COALESCE(
         (SELECT MAX(attempt_time)
          FROM   login_attempts
          WHERE  LOWER(email_entered) = LOWER('merchant.user@example.com')
            AND  is_successful = TRUE),
         TIMESTAMP '1970-01-01 00:00:00'
       );


-- ----------------------------------------------------------------------------
-- 7. Active sessions
--    Supports: TC_LOGIN_018, TC_LOGIN_019, TC_LOGIN_020, TC_LOGIN_022,
--              TC_LOGIN_023, and BUG_LOGIN_003
--    During TC_LOGIN_018 two active rows are expected. After logout the row
--    must be inactive with logged_out_at populated. A row still marked active
--    after logout is the evidence to attach to BUG_LOGIN_003.
-- ----------------------------------------------------------------------------
SELECT s.session_id,
       s.user_id,
       u.email,
       s.created_at,
       s.last_activity_at,
       s.expires_at,
       s.is_active,
       s.logged_out_at
FROM   user_sessions s
JOIN   users u ON u.user_id = s.user_id
WHERE  LOWER(u.email) = LOWER('merchant.user@example.com')
ORDER BY s.created_at DESC;

-- Sessions still marked active although the 15-minute idle timeout has
-- already passed. Per requirement R5 this result set should be empty.
SELECT s.session_id,
       u.email,
       s.last_activity_at,
       ROUND(EXTRACT(EPOCH FROM (NOW() - s.last_activity_at)) / 60) AS idle_minutes
FROM   user_sessions s
JOIN   users u ON u.user_id = s.user_id
WHERE  s.is_active = TRUE
  AND  s.last_activity_at < NOW() - INTERVAL '15 minutes';


-- ----------------------------------------------------------------------------
-- 8. Password reset tokens
--    Supports: TC_LOGIN_015, TC_LOGIN_016
--    Confirms the token lifetime is 15 minutes and that a used token is
--    marked as used rather than left reusable.
-- ----------------------------------------------------------------------------
SELECT r.reset_id,
       u.email,
       r.created_at,
       r.expires_at,
       ROUND(EXTRACT(EPOCH FROM (r.expires_at - r.created_at)) / 60) AS token_lifetime_minutes,
       r.is_used,
       r.used_at
FROM   password_resets r
JOIN   users u ON u.user_id = r.user_id
WHERE  LOWER(u.email) = LOWER('merchant.user@example.com')
ORDER BY r.created_at DESC;

-- Tokens that are past their expiry but still marked unused and therefore
-- potentially usable. Per requirement R6 this result set should be empty.
SELECT reset_id,
       user_id,
       expires_at,
       is_used
FROM   password_resets
WHERE  is_used = FALSE
  AND  expires_at < NOW();
