-- 
-- Table to map OAuth accounts with our user_id
-- 
-- Notes:
-- ------
--      n.a.
-- 
-- Overview:
-- ---------
--    (A) Required Types
--    (B) Table auth.users
--    (C) Triggers for auth.users
--    (D) Other Functions for auth.users
-- 


-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------

CREATE TYPE
auth.provider_t AS ENUM ('google')
;

-- -----------------------------------------------------------------------
-- (B) TABLE auth.linkedoauth
-- -----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS
auth.linkedoauth (
    linkage_id     uuid DEFAULT uuid_generate_v4()
  -- see auth.emails.user_id
  , user_id        uuid NOT NULL
  -- OAuth information
  , provider_name  auth.provider_t NOT NULL
  , account_id     text NOT NULL
  -- documentation
  , created_at     timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by     text NOT NULL default CURRENT_USER
  , PRIMARY KEY(linkage_id)
);

-- Unique Keys
-- Also Search: WHERE user_id=??? AND provider_name=???
CREATE UNIQUE INDEX CONCURRENTLY "uk_linkedoauth_1" 
  ON auth.linkedoauth USING BTREE (user_id, provider_name)
;

-- Never store the accountID twice for a given provider
CREATE UNIQUE INDEX CONCURRENTLY "uk_linkedoauth_2" 
  ON auth.linkedoauth USING BTREE (provider_name, account_id)
;

-- Find all providers linked with user_id
-- Search: WHERE user_id=???
CREATE INDEX CONCURRENTLY "bt_linkedoauth_3" 
  ON auth.linkedoauth USING BTREE (user_id)
;

-- -----------------------------------------------------------------------
-- (C) TRIGGERS for auth.linkedoauth
-- -----------------------------------------------------------------------

-- n.a.

-- -----------------------------------------------------------------------
-- (D) FUNCTIONS for auth.emails
--  SignIn
--      - `upsert_google_signin`
-- -----------------------------------------------------------------------


-- 
-- Link new Google Account or validate an existing Google Account
-- 
-- HOW IT WORKS:
--    (1) Lookup up ('google', gid) in auth.linkedoauth 
--        Yes: Return `user_id` 
--        No: Go to (2)
--    (2) Lookup up (email) in auth.emails 
--        Yes: Get `user_id`
--        No: Add (email, random pw, isactive=t) to auth.emails
--    (3) Store (user_id, 'google', gid)
--    (4) Return `user_id`
--  
-- USAGE:
--    SELECT auth.upsert_google_signin('JJKJKJKJ38282', 'my@email.com');
-- 
-- RETURN
--    uuid  Out `user_id`
-- 
-- DROP FUNCTION IF EXISTS auth.upsert_google_signin;
CREATE OR REPLACE FUNCTION auth.upsert_google_signin(
    the_gid text, the_email auth.email_t)
  RETURNS uuid AS
$$
DECLARE
  the_user_id uuid;
BEGIN
  -- (1) Lookup up ('google', gid) in auth.linkedoauth 
  the_user_id := (SELECT user_id FROM auth.linkedoauth 
                  WHERE provider_name='google' AND account_id=the_gid);
  IF the_user_id IS NOT NULL THEN
    RETURN the_user_id;
  END IF;

  -- (2) Lookup up (email) in auth.emails 
  the_user_id := (SELECT auth.lookup_userid_by_email(the_email));

  IF the_user_id IS NULL THEN
    -- Add (email, random pw, isactive=t) to auth.emails
    INSERT INTO auth.emails(email, hashed_password, isactive) 
    VALUES (the_email::auth.email_t, sha512((random()::text)::bytea), TRUE)
    RETURNING user_id INTO the_user_id
    ;
  END IF;

  -- (3) Store (user_id, 'google', gid)
  INSERT INTO auth.linkedoauth(user_id, provider_name, account_id)
  VALUES (the_user_id, 'google', the_gid)
  ;

  RETURN the_user_id;
END;
$$ 
LANGUAGE plpgsql
;
