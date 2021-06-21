-- 
-- Table for users' Email and Password
-- 
-- Notes:
-- ------
--    - The Email serves as recovery Email and is mutable!
--    - Delete not activated (isactive=False) Accounts after 24 hours.
-- 
-- Overview:
-- ---------
--    (A) Required Types
--    (B) Table auth.emails
--    (C) Triggers for auth.emails
--    (D) Other Functions for auth.emails
-- 


-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------


-- 
-- auth.email_t (type check)
--    - https://html.spec.whatwg.org/multipage/input.html#e-mail-state-(type=email)
-- 
-- USAGE:
--    SELECT 'coolname123@example.com'::auth.email_t;  -- Ok
--    SELECT 'BIGLETTER@example.com'::auth.email_t; -- Fails
--    SELECT 'nohost'::auth.email_t; -- Fails
-- 

-- DROP DOMAIN IF EXISTS auth.email_t;
CREATE DOMAIN auth.email_t AS text
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );


-- -----------------------------------------------------------------------
-- (B) TABLE auth.email
-- -----------------------------------------------------------------------

-- delete table
-- DROP TABLE IF EXISTS  auth.email;

-- setup the table again
CREATE TABLE IF NOT EXISTS
auth.emails (   -- LEGACY!
  -- automatic immutable fields
    user_id        uuid DEFAULT uuid_generate_v4()
  -- mutable fields
  , email          auth.email_t NOT NULL
  , hashed_password   bytea NOT NULL
  -- automatic mutable fields
  , isactive       boolean default FALSE
  -- documentation
  , created_at     timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by     text NOT NULL default CURRENT_USER
  , PRIMARY KEY(user_id)
);

-- keys
CREATE UNIQUE INDEX CONCURRENTLY "uk_emails_1" 
  ON auth.emails USING BTREE (email)
; -- for "="

-- search: WHERE email=e AND hashed_password=pw
CREATE INDEX CONCURRENTLY "bt_emails_2" 
  ON auth.emails USING BTREE (email, hashed_password)
; -- for "="

-- search: WHERE isactive=0 AND created_at < (NOW()::timestamp - interval '24 hours')
-- BRIN cannot deal with boolean
CREATE INDEX CONCURRENTLY "brn_emails_3" 
  ON auth.emails USING BRIN (created_at)
;


-- Kommentare
COMMENT ON COLUMN auth.emails.user_id IS 
  'Autogenerated UserId that is exposed to other applications.'
;
COMMENT ON COLUMN auth.emails.email IS 
  'The Email for login, verfication and password recovery.'
;
COMMENT ON COLUMN auth.emails.hashed_password IS 
  'SHA-512 has of the password string. The blank password is never stored.'
;
COMMENT ON COLUMN auth.emails.isactive IS 
  'Flag if the account have been verfified (by Verification Email). Default is FALSE.'
;



-- -----------------------------------------------------------------------
-- (C) TRIGGERS for auth.email
--    - Prevent row DELETE
--    - Prevent UPDATE on user_id, created_at, created_by, email
-- -----------------------------------------------------------------------

-- 
-- Utility Function
-- - Raise an exception in a statement level trigger
-- - row level trigger functions are working as well
-- 
CREATE OR REPLACE FUNCTION auth.utils_raise_exception()
  RETURNS TRIGGER AS
$$
DECLARE
  errmsg text;
BEGIN
  errmsg := TG_ARGV[0];
  RAISE EXCEPTION '%s', errmsg;
END;
$$ 
LANGUAGE plpgsql
;

-- 
-- Prevent UPDATE on user_id, created_at, created_by
-- - these fields are immutable
-- 

-- DROP TRIGGER IF EXISTS trg_prevent_update_user_id ON auth.emails;
CREATE TRIGGER trg_prevent_update_user_id
  BEFORE UPDATE 
    OF user_id ON auth.emails
  FOR EACH STATEMENT 
    EXECUTE PROCEDURE auth.utils_raise_exception(
      'UPDATE of auth.emails.user_id is forbidden.')
;

-- DROP TRIGGER IF EXISTS trg_prevent_update_created_at ON auth.emails;
CREATE TRIGGER trg_prevent_update_created_at
  BEFORE UPDATE 
    OF created_at ON auth.emails
  FOR EACH STATEMENT 
    EXECUTE PROCEDURE auth.utils_raise_exception(
      'UPDATE of auth.emails.created_at is forbidden.')
;

-- DROP TRIGGER IF EXISTS trg_prevent_update_created_by ON auth.emails;
CREATE TRIGGER trg_prevent_update_created_by
  BEFORE UPDATE 
    OF created_by ON auth.emails
  FOR EACH STATEMENT 
    EXECUTE PROCEDURE auth.utils_raise_exception(
      'UPDATE of auth.emails.created_by is forbidden.')
;



-- -----------------------------------------------------------------------
-- (D) FUNCTIONS for auth.emails
--  SignUp
--      - Add new user (auth.add_new_email_account)
--  Login
--      - Validate email and password (auth.validate_email_password)
--      - Check if email is active (auth.email_isactive)
--  Recovery
--  - lookup_userid_by_email
-- -----------------------------------------------------------------------


-- 
-- Add a new user (returns: uuid)
-- 
-- PURPOSE: SignUp
-- 
-- USAGE:
--    SELECT auth.add_new_email_account('new@email.com', 'secretpw');
-- 
-- RETURN
--    uuid  The unique user_id
-- 
-- DROP FUNCTION IF EXISTS auth.add_new_email_account;
CREATE OR REPLACE FUNCTION auth.add_new_email_account(
    the_email auth.email_t, plainpassword text)
  RETURNS uuid AS
$$
DECLARE
  newuser_id uuid;
BEGIN
  -- Delete not activated accounts after 24 hours
  DELETE FROM auth.emails
  WHERE isactive = FALSE 
    AND created_at < (NOW()::timestamp - interval '24 hours')
  ;
  -- add new user 
  INSERT INTO auth.emails(email, hashed_password) 
  VALUES (
    the_email::auth.email_t, 
    sha512(plainpassword::bytea)
  )
  ON CONFLICT DO NOTHING
  ;
  RETURN auth.lookup_userid_by_email(the_email::auth.email_t);
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- Validate user account (returns: bool)
-- 
-- PURPOSE: Login
-- 
-- USAGE:
--    SELECT auth.validate_email_password('new@email.com', 'secretpw');
-- 
-- RETURN
--    bool  True if email/password exists
-- 
-- DROP FUNCTION IF EXISTS auth.validate_email_password;
CREATE OR REPLACE FUNCTION auth.validate_email_password(
    the_email auth.email_t, plainpassword text)
  RETURNS bool AS
$$
BEGIN
  IF (SELECT COUNT(user_id) FROM auth.emails 
      WHERE email = the_email::auth.email_t
        AND hashed_password = sha512(plainpassword::bytea)
     ) = 1 
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ 
LANGUAGE plpgsql
;

-- Variant: Returns user_id
CREATE OR REPLACE FUNCTION auth.validate_email_password2(
    the_email auth.email_t, plainpassword text)
  RETURNS uuid AS
$$
BEGIN
  RETURN (SELECT user_id FROM auth.emails 
           WHERE email = the_email::auth.email_t
             AND hashed_password = sha512(plainpassword::bytea)
         );
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- Check if user_id is active (returns: bool)
-- 
-- PURPOSE: Login
-- 
-- USAGE:
--    SELECT auth.email_isactive('3d376550-5265-4830-9812-5e9a84cdfa29');
-- 
-- RETURN
--    bool  True if it worked, and False if it failed.
-- 
-- DROP FUNCTION IF EXISTS auth.email_isactive;
CREATE OR REPLACE FUNCTION auth.email_isactive(theuserid uuid)
  RETURNS bool AS
$$
BEGIN
  RETURN (SELECT isactive FROM auth.emails WHERE user_id = theuserid);
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- Get UserId by email (returns: uuid)
-- 
-- PURPOSE: Account Recovery
-- 
-- USAGE:
--    SELECT auth.lookup_userid_by_email('name@email.com');
-- 
-- RETURN
--    uuid  The unique UserId
-- 
-- DROP FUNCTION IF EXISTS auth.lookup_userid_by_email;
CREATE OR REPLACE FUNCTION auth.lookup_userid_by_email(theemail auth.email_t)
  RETURNS uuid AS
$$
BEGIN
  RETURN (SELECT user_id FROM auth.emails WHERE email = theemail);
END;
$$ 
LANGUAGE plpgsql
;