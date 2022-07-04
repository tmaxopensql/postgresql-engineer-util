/*live tuple, dead tuple check*/
SELECT
    	c.relname AS table_name,
    	pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid) as total_tuple,
    	pg_stat_get_live_tuples(c.oid) AS live_tuple,
    	pg_stat_get_dead_tuples(c.oid) AS dead_tupple,
    	CASE WHEN pg_stat_get_live_tuples(c.oid) = 0 and pg_stat_get_dead_tuples(c.oid)=0 then 0
    	ELSE round(100*pg_stat_get_live_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2)
    	END ||'%' as live_tuple_rate
/*    	CASE WHEN pg_stat_get_live_tuples(c.oid) = 0 and pg_stat_get_dead_tuples(c.oid)=0 then 0
    	ELSE round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2)
    	END ||'%' as dead_tuple_rate*/
FROM 
	pg_class AS c, pg_stat_user_tables AS u, pg_namespace AS n
WHERE 
	n.oid = c.relnamespace AND c.relname = u.relname
ORDER BY dead_tupple DESC;
