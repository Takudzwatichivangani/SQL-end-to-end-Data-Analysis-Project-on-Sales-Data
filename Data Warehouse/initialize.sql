/*
============================================================
DATABASE INITIALIZATION — SCHEMA SETUP
============================================================

DESCRIPTION
------------------------------------------------------------
This SQL script initializes the project database by:

1. Dropping existing Bronze, Silver, and Gold schemas if they exist.
2. Creating fresh Bronze and Silver schemas to load raw and cleaned data.
3. Preparing the environment for subsequent ETL and analytics tasks.
============================================================
*/

-- Dropping schemas if they exist
DROP SCHEMA IF EXISTS bbronze;
DROP SCHEMA IF EXISTS ssilver;
DROP SCHEMA IF EXISTS ggold;

-- Creating Schemas
CREATE SCHEMA IF NOT EXISTS bbronze;
CREATE SCHEMA IF NOT EXISTS ssilver;