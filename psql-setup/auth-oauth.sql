--
-- (DRAFT!)
-- OAuth Authentication Services
--  - Store the tokens for different services
--  - 1 userid, N services
-- 
-- Requires
--  - Table: auth.users
-- 

-- List of OAuth services
CREATE TYPE 
auth.service_t 
as ENUM('orcid', 'openid', 'google', 'facebook')
;

-- delete table
-- DROP TABLE IF EXISTS  auth.users;

-- setup table again
CREATE TABLE
IF NOT EXISTS
auth.oauth (
    id          bigint GENERATED ALWAYS AS IDENTITY
  , userid      bigint NOT NULL
  , services    auth.service_t NOT NULL
  , token       character(128) NOT NULL
  , CONSTRAINT fk_auth_oauth_1
      FOREIGN KEY(userid)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
  , UNIQUE(userid, services)
);

COMMENT ON COLUMN auth.oauth.id IS 'The table ID, do not use it as foreign key in other tables.';
COMMENT ON COLUMN auth.oauth.userid IS 'The unique UserId from auth.users table.';
COMMENT ON COLUMN auth.oauth.services IS 'Name of the OAuth service';
COMMENT ON COLUMN auth.oauth.token IS 'The access token (JWT) fot the OAuth service';


