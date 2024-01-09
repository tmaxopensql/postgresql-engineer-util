/*live tuple, dead tuple check*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid) as Total,
    pg_stat_get_live_tuples(c.oid) AS Live,
    pg_stat_get_dead_tuples(c.oid) AS Dead,
    round(100*pg_stat_get_live_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) as Live_rate,
    round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) as Dead_rate,
    CASE WHEN round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) >= 10.00 then 'VACUUM FULL RECOMMEND'
         WHEN round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) >= 5.00 and round(100*pg_stat_get_dead_tuples(c.oid) / (pg_stat_get_live_tuples(c.oid) + pg_stat_get_dead_tuples(c.oid)),2) < 10.00 then 'STANDARD VACUUM RECOMMEND'
    ELSE 'NORMAL STATE' end as "VACUUM FULL NEED"
FROM pg_class AS c
JOIN pg_catalog.pg_namespace AS n
  ON n.oid = c.relnamespace
WHERE
  pg_stat_get_live_tuples(c.oid) > 0
  AND c.relname NOT LIKE 'pg_%'
  AND n.nspname NOT LIKE 'information%'
ORDER BY Dead_rate DESC, Total DESC;
