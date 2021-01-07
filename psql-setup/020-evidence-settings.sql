-- 
-- Store User Settings for the App
-- 
CREATE TABLE IF NOT EXISTS 
evidence.user_settings (
    row_id      uuid DEFAULT uuid_generate_v4()
  , username    text NOT NULL
  , settings    JSONB DEFAULT NULL
  , PRIMARY KEY(row_id)
  , UNIQUE(username)
);

COMMENT ON COLUMN evidence.user_settings.row_id IS 
  'Internal primary key (UUID4) of the table for SQL purposes (e.g. join, foreign key). In our case this row_id has no meaning';
COMMENT ON COLUMN evidence.user_settings.username IS 
  'Unique username from an authentification database. Currently the app uses `auth.users.username` what is planned to be replaced by an DWDS Auth API.';
COMMENT ON COLUMN evidence.user_settings.settings IS 
  'JSON with all user specific settings. Usually the whole JSON object is updated.';


-- 
-- Upsert function
-- 
-- EXAMPLE:
-- --------
--    SELECT evidence.upsert_user_settings('testuser2', '{"hello": "world1"}'::jsonb);
--    SELECT settings->'hello' FROM evidence.user_settings;
-- 
CREATE OR REPLACE FUNCTION evidence.upsert_user_settings(
    theusername text, thesettings jsonb)
  RETURNS bool AS
$$
BEGIN
  -- try to insert new row
  INSERT INTO evidence.user_settings (username, settings) 
       VALUES (theusername::text, thesettings::jsonb)
  -- update if error occured
  ON CONFLICT (username) 
  DO UPDATE SET settings = thesettings::jsonb
  ;
  RETURN TRUE;
END;
$$ 
LANGUAGE plpgsql
;

