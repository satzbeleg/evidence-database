-- 
-- Run the install.sql script to setup the database extensions, schema, tables, etc.
-- the database is assumed to be named 'postgres'
-- 

-- 
-- Load the extensions for the database
-- 
-- CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION btree_gist;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 
-- Create schemes
-- 
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS userdata;
