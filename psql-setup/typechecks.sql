-- 
-- email (type check)
-- 
-- USAGE:
--      SELECT 'asdf@foobar.com'::email;  -- Ok
--      SELECT 'asd@f@foobar.com'::email; -- Fails
--  
-- LINKS
-- - https://dba.stackexchange.com/a/165923
-- 

DROP DOMAIN IF EXISTS email;
CREATE DOMAIN email AS citext
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' )
;

DROP DOMAIN IF EXISTS username;
CREATE DOMAIN username AS citext
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]' )
;

