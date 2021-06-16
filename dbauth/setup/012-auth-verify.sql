-- 
-- Table with Email Verification Tokens
-- 
-- Notes:
-- ------
--    - The table `auth.verify` stores verfication tokens sent to the
--      user's email account
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

-- n.a.

-- -----------------------------------------------------------------------
-- (B) TABLE auth.verify
-- -----------------------------------------------------------------------

-- delete table
-- DROP TABLE IF EXISTS  auth.verify;

-- setup the table again
CREATE TABLE IF NOT EXISTS
auth.verify (   -- LEGACY!
    token       uuid DEFAULT uuid_generate_v4()
  , user_id     uuid NOT NULL
  , created_at  timestamp NOT NULL default CURRENT_TIMESTAMP
  , PRIMARY KEY(token)
);

-- search: where created_at < (NOW()::timestamp - interval '3 hours')
CREATE INDEX CONCURRENTLY "bi_verify_1" 
  ON auth.verify USING brin(created_at)
;


-- -----------------------------------------------------------------------
-- (C) TRIGGERS 
-- -----------------------------------------------------------------------

-- purge old tokens before any insert query
CREATE FUNCTION auth.purge_old_verification_tokens() 
  RETURNS TRIGGER AS 
$$
BEGIN
  DELETE FROM auth.verify
  WHERE created_at < (NOW()::timestamp - interval '3 hours')
  ;
  RETURN NULL;
END;
$$ 
LANGUAGE plpgsql
;

CREATE TRIGGER trg_purge_old_verification_tokens
  BEFORE INSERT 
    ON auth.verify
  FOR EACH STATEMENT
    EXECUTE PROCEDURE auth.purge_old_verification_tokens()
;

-- -----------------------------------------------------------------------
-- (D) FUNCTIONS 
-- -----------------------------------------------------------------------

-- Issue a verification token with
CREATE FUNCTION auth.issue_verify_token(the_user_id uuid) 
  RETURNS uuid AS 
$$
BEGIN
  INSERT INTO auth.verify(user_id)
       VALUES (the_user_id::uuid)
  RETURNING token 
  ;
  RETURN token;
END;
$$ 
LANGUAGE plpgsql
;

-- Verify token
CREATE FUNCTION auth.verify_token(the_token uuid) 
  RETURNS text AS 
$$
BEGIN
  -- Delete old tokens
  DELETE FROM auth.verify
  WHERE created_at < (NOW()::timestamp - interval '3 hours')
  ;
  -- Find associated UserID of the token, and set user_id to active
  UPDATE auth.email
     SET isactive = TRUE
   WHERE user_id = (SELECT user_id FROM auth.verify 
                    WHERE token = the_token LIMIT 1)::uuid
  RETURNING user_id as the_user_id
  ;
  -- Delete issued token
  DELETE FROM auth.verify
  WHERE token = the_token
  ;
  -- done
  RETURN the_user_id::text;
END;
$$ 
LANGUAGE plpgsql
;