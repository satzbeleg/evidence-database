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
    id          uuid DEFAULT uuid_generate_v4() 
  , user_id     uuid NOT NULL
  , username    username NOT NULL
  , email       email NOT NULL
  , passw       bytea NOT NULL
  , PRIMARY KEY(id)
  , CONSTRAINT fk_auth_local_1
      FOREIGN KEY(user_id)
        REFERENCES auth.users(user_id)
        ON DELETE CASCADE
  , UNIQUE(username)
  , UNIQUE(email)
);

COMMENT ON COLUMN auth.localpw.id IS 'The table ID, do not use it as foreign key in other tables.';
COMMENT ON COLUMN auth.localpw.user_id IS 'The unique UserId from auth.users table.';
COMMENT ON COLUMN auth.localpw.username IS 'Username, user handle, or nickname.';
COMMENT ON COLUMN auth.localpw.email IS 'Email address for authentification and password recovery purposes';
COMMENT ON COLUMN auth.localpw.passw IS 'SHA-512 has of the password string.';


-- Type checks for INSERT, UPDATE


