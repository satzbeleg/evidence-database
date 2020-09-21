-- 
-- (DRAFT!)
-- Local Authentication with username/email and password
-- 
-- Requires
--  - Table: auth.users
--  - Type check: email
--  - Type check: username
-- 


-- delete table
-- DROP TABLE IF EXISTS  auth.localpw;

-- setup the table again
CREATE TABLE
IF NOT EXISTS
auth.localpw (
    id          bigint GENERATED ALWAYS AS IDENTITY
  , userid      bigint
  , username    username NOT NULL
  , email       email NOT NULL
  , passw       bytea NOT NULL
  , PRIMARY KEY(id)
  , CONSTRAINT fk_auth_local_1
      FOREIGN KEY(userid)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
  , UNIQUE(username)
  , UNIQUE(email)
);

COMMENT ON COLUMN auth.localpw.id IS 'The table ID, do not use it as foreign key in other tables.';
COMMENT ON COLUMN auth.localpw.userid IS 'The unique UserId from auth.users table.';
COMMENT ON COLUMN auth.localpw.username IS 'Username, user handle, or nickname.';
COMMENT ON COLUMN auth.localpw.email IS 'Email address for authentification and password recovery purposes';
COMMENT ON COLUMN auth.localpw.passw IS 'SHA-512 has of the password string.';


-- Type checks for INSERT, UPDATE


