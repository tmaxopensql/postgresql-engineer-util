
/*
SELECT
	relname AS "table_name", 
	pg_size_pretty(pg_table_size(C.oid)) AS "table_size" 
FROM 
	pg_class C 
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) 
WHERE 
	nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r') 
ORDER BY pg_table_size(C.oid) 
DESC LIMIT 5;
*/

/* table size */
/*
SELECT 
	relname AS "table_name",
	pg_size_pretty(pg_table_size(C.oid)) AS "table_size"
FROM 
	pg_class C, pg_namespace N
where 
	N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
ORDER BY pg_table_size(C.oid)
DESC LIMIT 5;
*/


with
all_tables as
(
SELECT  
	*
FROM (
SELECT 
	'all_tables'::text AS table_name,
	pg_size_pretty(sum(pg_table_size(C.oid))) AS table_size
FROM 
	pg_class C, pg_namespace N
where 
	N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
)a),
tables as
(
SELECT  
	*
FROM (
SELECT 
	relname AS table_name,
	pg_size_pretty(pg_table_size(C.oid)) AS table_size
FROM 
	pg_class C, pg_namespace N
where 
	N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
)a)
SELECT  
	table_name as table_name,
    	table_size as table_size
FROM 
	(SELECT * FROM all_tables UNION ALL SELECT * FROM tables) a;


/* index size */
/*
SELECT 
	relname AS table_name,
	pg_size_pretty(pg_table_size(C.oid)) AS table_size
FROM
	pg_class C, pg_namespace N
where 
	N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
ORDER BY pg_indexes_size(C.oid)
DESC LIMIT 5;
*/



with
all_tables as
(
SELECT
        *
FROM (
SELECT
        'all_tables'::text AS table_name,
        'all_indexes'::text AS index_name,
        pg_size_pretty(sum(pg_relation_size(i.indexname::TEXT))) AS index_size
FROM
        pg_class C Left OUTER JOIN pg_indexes i on  C.relname = i.tablename,
        pg_namespace N
where
        N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
)a),
tables as
(
SELECT
        *
FROM (
SELECT
        C.relname AS table_name,
        i.indexname AS index_name,
        pg_size_pretty(pg_relation_size(i.indexname::TEXT)) AS index_size
FROM
        pg_class C Left OUTER JOIN pg_indexes i on  C.relname = i.tablename,
        pg_namespace N
where
        N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
)a)
SELECT
        table_name as table_name,
        index_name as index_name,
        index_size as index_size
FROM
        (SELECT * FROM all_tables UNION ALL SELECT * FROM tables) a;


/*
SELECT
    	c.relname AS table_name,
    	pg_size_pretty(pg_total_relation_size(c.oid)) as total_relation_size,
--  	pg_size_pretty(pg_relation_size(c.oid)) as relation_size
FROM 
	pg_class AS c, pg_stat_user_tables AS u, pg_namespace AS n
WHERE 
	n.oid = c.relnamespace AND c.relname = u.relname
;
*/

with
all_tables as
(
SELECT  
	*
FROM (
SELECT 
	'all_tables'::text AS table_name,
	pg_size_pretty(sum(pg_total_relation_size(C.oid))) AS total_relation_size
FROM 
	pg_class C, pg_namespace N
where 
	N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
)a),
tables as
(
SELECT  
	*
FROM (
SELECT 
	relname AS table_name,
	pg_size_pretty(pg_total_relation_size(C.oid)) AS total_relation_size
FROM 
	pg_class C, pg_namespace N
where 
	N.oid = C.relnamespace and nspname NOT IN ('pg_catalog', 'information_schema') AND nspname !~ '^pg_toast' AND relkind IN ('r')
)a)
SELECT  
	table_name as table_name,
    	total_relation_size as total_relation_size
FROM 
	(SELECT * FROM all_tables UNION ALL SELECT * FROM tables) a;
