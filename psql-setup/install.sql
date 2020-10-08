-- 
-- Run the install.sql script to setup the database extensions, schema, tables, etc.
-- the database is assumed to be named 'postgres'
-- 

-- 
-- Load the extensions for the database
-- 
CREATE EXTENSION IF NOT EXISTS citus;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 
-- Create schemes
-- 
DROP SCHEMA IF EXISTS auth CASCADE;
DROP SCHEMA IF EXISTS evidence CASCADE;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS evidence;


-- Type checks
\i typechecks.sql

-- 
-- Authentication
--  1a. Look up username/email (see auth.localpw)
--  1b. Auth with an OAuth server (sse auth.oauth)
--  2. Proceed with using the UserId (see auth.users.id)
-- 
\i auth-users.sql
\i auth-burnedpw.sql
\i auth-localpw.sql
\i auth-oauth.sql

-- \i evidence-results.sql
-- \i evidence-scores.sql

-- 
-- Demo data
-- 
