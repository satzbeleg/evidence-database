-- 
-- (DRAFT!)
-- Table with UserIDs
-- 

-- Sign Up Stages
CREATE TYPE 
auth.user_lifecycle_t 
as ENUM(
  'user_id-created', 
  'username-exists', 
  'email-exists', 
  'account-deactivated', 
  'account-deletion-pending', 
  'account-deleted'
);


-- delete table
-- DROP TABLE IF EXISTS  auth.users;

-- setup the table again
CREATE TABLE
IF NOT EXISTS
auth.users (
    user_id     uuid DEFAULT uuid_generate_v4()
  , otherinfo   JSONB NOT NULL
  , status      auth.user_lifecycle_t DEFAULT 'user_id-created'
  , created_at  timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by  text NOT NULL default CURRENT_USER
  , PRIMARY KEY(user_id)
);

-- 
-- insert some mock up data
-- 
INSERT INTO auth.users(otherinfo)
VALUES ('{"created_by": "bofh@nowhere.com", "created_at": "howto automagic dates" }'::jsonb);


-- 
-- Prevent deletion of any row
-- 
CREATE OR REPLACE FUNCTION auth.abort_user_deletion()
  RETURNS TRIGGER AS
$$
BEGIN
  RAISE EXCEPTION 'Attempt to delete UserID: %', OLD.user_id;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS prevent_user_deletion ON auth.users;

CREATE TRIGGER prevent_user_deletion
  BEFORE DELETE ON auth.users 
  FOR EACH ROW 
  EXECUTE PROCEDURE auth.abort_user_deletion()
;

-- test it
SELECT * FROM auth.users;
DELETE FROM auth.users WHERE user_id in (SELECT user_id FROM auth.users LIMIT 1);
