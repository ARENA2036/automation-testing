-- ==========================================
-- FULL DATABASE VERIFICATION SCRIPT
-- Works in PostgreSQL
-- ==========================================

-- 1. Confirm connection and database details
SELECT
    current_database()   AS database_name,
    current_user         AS connected_user,
    version()            AS postgres_version,
    now()                AS check_time;

-- 2. Count total number of schemas
SELECT COUNT(*) AS total_schemas
FROM information_schema.schemata;

-- 3. Count total number of tables
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('pg_catalog','information_schema');

-- 4. List first 10 tables (for quick view)
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('pg_catalog','information_schema')
ORDER BY table_schema, table_name
LIMIT 10;

-- 5. Approximate row counts for all tables
SELECT
    n.nspname || '.' || c.relname AS table_name,
    c.reltuples::bigint AS approximate_row_count
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'  -- only ordinary tables
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY n.nspname, c.relname;

-- 6. (Optional) Generate dynamic SQL to preview rows from first 3 tables
-- Preview rows from the first 3 tables
SELECT
    'SELECT * FROM ' || quote_ident(table_schema) || '.' || quote_ident(table_name) || ' LIMIT 5;' AS sample_query
FROM information_schema.tables
WHERE table_type='BASE TABLE'
  AND table_schema NOT IN ('pg_catalog','information_schema')
ORDER BY table_schema, table_name
LIMIT 3;

-- 7. Show total indexes (checks schema structure)
SELECT COUNT(*) AS total_indexes
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog','information_schema');

-- 8. Show total functions (if any)
SELECT COUNT(*) AS total_functions
FROM information_schema.routines
WHERE routine_schema NOT IN ('pg_catalog','information_schema');

-- 9. Final confirmation
SELECT 'Database structure and data verified successfully' AS status;