-- 
-- Store User Settings for the App
-- 
CREATE TABLE IF NOT EXISTS 
evidence.user_settings (
    row_id      uuid DEFAULT uuid_generate_v4()
  , username    text NOT NULL  -- immutable field
  , settings    JSONB DEFAULT NULL   -- mutable field
  , PRIMARY KEY(row_id)
);

-- keys
CREATE UNIQUE INDEX CONCURRENTLY "uk_user_settings_1" 
  ON evidence.user_settings USING BTREE (username)
;

-- search by: (username), settings
CREATE INDEX CONCURRENTLY "gin_user_settings_2"
  ON evidence.user_settings USING GIN (settings)
;

-- Kommentare
COMMENT ON COLUMN evidence.user_settings.row_id IS 
  'Internal primary key (UUID4) of the table for SQL purposes (e.g. join, foreign key). In our case this row_id has no meaning'
;
COMMENT ON COLUMN evidence.user_settings.username IS 
  'Unique username from an authentification database. Currently the app uses `auth.users.username` what is planned to be replaced by an DWDS Auth API.'
;
COMMENT ON COLUMN evidence.user_settings.settings IS 
  'JSON with all user specific settings. Usually the whole JSON object is updated.'
;


-- 
-- Upsert function
-- 
-- EXAMPLE:
-- --------
--    SELECT evidence.upsert_user_settings('testuser2', '{"hello": "world1"}'::jsonb);
--    SELECT settings->'hello' FROM evidence.user_settings;
--    SELECT * FROM evidence.user_settings;
-- 
-- DROP FUNCTION evidence.upsert_user_settings(text,jsonb);
CREATE OR REPLACE FUNCTION evidence.upsert_user_settings(
    theusername text, thesettings jsonb)
  RETURNS uuid AS
$$
DECLARE
  the_row_id uuid;
BEGIN
  -- try to insert new row
  INSERT INTO evidence.user_settings (username, settings) 
       VALUES (theusername::text, thesettings::jsonb)
  ON CONFLICT (username) 
  DO UPDATE SET settings = user_settings.settings || EXCLUDED.settings
  RETURNING row_id INTO the_row_id
  ;
  RETURN the_row_id;
END;
$$ 
LANGUAGE plpgsql
;

