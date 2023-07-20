/*live tuple, dead tuple check*/
/*
SELECT
    	c.relname AS table_name,
    	pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid) as total_tuple,
    	pg_stat_get_live_tuples(c.oid) AS live_tuple,
    	pg_stat_get_dead_tuples(c.oid) AS dead_tupple,
    	CASE WHEN pg_stat_get_live_tuples(c.oid) = 0 and pg_stat_get_dead_tuples(c.oid)=0 then 0
    	ELSE round(100*pg_stat_get_live_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2)
    	END ||'%' as live_tuple_rate
FROM 
	pg_class AS c, pg_stat_user_tables AS u, pg_namespace AS n
WHERE 
	n.oid = c.relnamespace AND c.relname = u.relname
ORDER BY dead_tupple DESC; */
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid) as total_tuple,
    pg_stat_get_live_tuples(c.oid) AS live_tuple,
    pg_stat_get_dead_tuples(c.oid) AS dead_tuple,
    round(100*pg_stat_get_live_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) as live_tuple_rate,
    round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) as dead_tuple_rate,
    CASE WHEN round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) >= 10.00 then 'VACUUM FULL RECOMMEND'
         WHEN round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) >= 5.00 and round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) < 10.00 then 'STANDARD VACUUM RECOMMEND' 
    ELSE 'NORMAL STATE' end as "VACUUM FULL NEED"
FROM pg_class AS c
JOIN pg_catalog.pg_namespace AS n
  ON n.oid = c.relnamespace 
WHERE 
  pg_stat_get_live_tuples(c.oid) > 0
  AND c.relname NOT LIKE 'pg_%'
ORDER BY dead_tuple DESC;
