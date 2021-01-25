-- 
-- Run the install.sql script to setup the database extensions, schema, tables, etc.
-- the database is assumed to be named 'postgres'
-- 

-- 
-- Load the extensions for the database
-- 
CREATE EXTENSION IF NOT EXISTS citus;
-- CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION btree_gist;
CREATE EXTENSION pg_trgm;

-- 
-- Create schemes
-- 
DROP SCHEMA IF EXISTS auth CASCADE;
DROP SCHEMA IF EXISTS evidence CASCADE;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS evidence;


-- 
-- 01x - Authentication
-- \i psql-setup/010-auth-users.sql
-- \i psql-setup/019-auth-prepopulate.sql
-- 

-- 
-- 02x - Evidence App Data
-- 
