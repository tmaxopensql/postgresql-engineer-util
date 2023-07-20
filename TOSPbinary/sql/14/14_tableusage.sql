SELECT
       relname AS "table_name",
       pg_size_pretty(pg_table_size(C.oid)) AS "table_size"
FROM
       pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
	nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
ORDER BY pg_table_size(C.oid)
DESC;

