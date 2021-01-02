-- 
-- Local Authentication with username/email and password
-- 
-- Overview:
-- ---------
--    (A) Required Types
--    (B) Table auth.burnedpw
--    (C) Table auth.localpw
--    (D) Triggers for auth.localpw
--    (E) Other Functions for auth.localpw
-- 



-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------

-- 
-- auth.email_t (type check)
-- 
-- USAGE:
--      SELECT 'asdf@foobar.com'::auth.email_t;  -- Ok
--      SELECT 'asd@f@foobar.com'::auth.email_t; -- Fails
--  
-- LINKS
-- - https://dba.stackexchange.com/a/165923
-- 
DROP DOMAIN IF EXISTS auth.email_t;
CREATE DOMAIN auth.email_t AS citext
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' )
;


-- 
-- auth.username_t (type check)
-- 
-- USAGE:
--    SELECT 'coolname123'::auth.username_t;  -- Ok
--    SELECT 'no#pe'::auth.username_t; -- Fails
-- 
-- BEHAVIOR
--    SELECT 'Capital'::auth.username_t = 'capital'::auth.username_t; -- True
--  
DROP DOMAIN IF EXISTS auth.username_t;
CREATE DOMAIN auth.username_t AS citext
  CHECK ( value ~ '^[a-zA-Z0-9]+$' )
;


-- -----------------------------------------------------------------------
-- (B) TABLE auth.burnedpw
-- -----------------------------------------------------------------------




-- -----------------------------------------------------------------------
-- (C) TABLE auth.localpw
-- -----------------------------------------------------------------------

-- delete table
-- DROP TABLE IF EXISTS  auth.localpw;

-- setup the table again
CREATE TABLE
IF NOT EXISTS
auth.localpw (
    id          uuid DEFAULT uuid_generate_v4() 
  , user_id     uuid NOT NULL
  , username    auth.username_t NOT NULL
  , recovery_email    auth.email_t NOT NULL
  , hashed_password   bytea NOT NULL
  , PRIMARY KEY(id)
  , CONSTRAINT fk_auth_localpw_1
      FOREIGN KEY(user_id)
        REFERENCES auth.users(user_id)
        ON DELETE CASCADE
  , UNIQUE(username)
  , UNIQUE(recovery_email)
);

COMMENT ON COLUMN auth.localpw.id
  IS 'The table ID, do not use it as foreign key in other tables.';
COMMENT ON COLUMN auth.localpw.user_id
  IS 'The unique UserId from auth.users table.';
COMMENT ON COLUMN auth.localpw.username
  IS 'The unique immutable username for authentification purposes. It is not possible to change the username lateron.';
COMMENT ON COLUMN auth.localpw.recovery_email 
  IS 'Email address for authentification and password recovery purposes';
COMMENT ON COLUMN auth.localpw.hashed_password 
  IS 'SHA-512 has of the password string. The blank password is never stored.';



-- -----------------------------------------------------------------------
-- (D) TRIGGERS for auth.localpw
-- -----------------------------------------------------------------------




-- -----------------------------------------------------------------------
-- (E) FUNCTIONS for auth.localpw
-- -----------------------------------------------------------------------

-- Type checks for INSERT, UPDATE

-- https://stackoverflow.com/questions/4547672/return-multiple-fields-as-a-record-in-postgresql-with-pl-pgsql

CREATE TYPE auth_localpw_type AS (
  username  username,
  dis
  passw     text
);

