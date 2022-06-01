-- 
-- Store User Settings for the App
-- 
CREATE TABLE IF NOT EXISTS 
userdata.user_settings (
    row_id      uuid DEFAULT uuid_generate_v4()
  , user_id     uuid NOT NULL  -- immutable field
  , settings    JSONB DEFAULT NULL   -- mutable field
  , PRIMARY KEY(row_id)
);

-- keys
DROP INDEX IF EXISTS userdata."uk_user_settings_1" ;
CREATE UNIQUE INDEX "uk_user_settings_1" 
  ON userdata.user_settings USING BTREE (user_id)
; -- for "="

-- search by: (user_id), settings
-- DROP INDEX IF EXISTS userdata."gin_user_settings_2" ;
-- CREATE INDEX "gin_user_settings_2"
--   ON userdata.user_settings USING GIN (settings jsonb_path_ops)
-- ;

-- column descriptions
COMMENT ON COLUMN userdata.user_settings.row_id IS 
  'Internal primary key (UUID4) of the table for SQL purposes (e.g. join, foreign key). In our case this row_id has no meaning'
;
COMMENT ON COLUMN userdata.user_settings.user_id IS 
  'Unique user_id from an authentification database. Currently the app uses `auth.users.user_id` what is planned to be replaced by an DWDS Auth API.'
;
COMMENT ON COLUMN userdata.user_settings.settings IS 
  'JSON with all user specific settings. Usually the whole JSON object is updated.'
;


-- 
-- Upsert function
-- 
-- EXAMPLE:
-- --------
--    SELECT userdata.upsert_user_settings('testuser2', '{"hello": "world1"}'::jsonb);
--    SELECT settings->'hello' FROM userdata.user_settings;
--    SELECT * FROM userdata.user_settings;
-- 
-- DROP FUNCTION userdata.upsert_user_settings(uuid,jsonb);
CREATE OR REPLACE FUNCTION userdata.upsert_user_settings(
    theusername uuid, thesettings jsonb)
  RETURNS uuid AS
$$
DECLARE
  the_row_id uuid;
BEGIN
  -- try to insert new row
  INSERT INTO userdata.user_settings (user_id, settings) 
       VALUES (theusername::uuid, thesettings::jsonb)
  ON CONFLICT (user_id) 
  DO UPDATE SET settings = user_settings.settings || EXCLUDED.settings
  RETURNING row_id INTO the_row_id
  ;
  RETURN the_row_id;
END;
$$ 
LANGUAGE plpgsql
;

