/*<index hit>*/
/*
SELECT 
	'index I/O' as hit_object,
  	coalesce(sum(idx_blks_read),0) as "Idx Disk Read",
  	coalesce(sum(idx_blks_hit),0)  as "Idx Cache Hit",
  	coalesce(round(sum(idx_blks_hit)*100/ sum(idx_blks_hit + idx_blks_read),2),0)||'%' as "Idx Hit Ratio"
FROM
  	pg_statio_user_indexes
where
	idx_blks_read > 0 and idx_blks_hit > 0;
*/

with
all_indexes as
(
SELECT  *
FROM    (
    SELECT  'all'::text as index_name,
        sum(coalesce(idx_blks_read,0)) as from_disk,
        sum(coalesce(idx_blks_hit,0)) as from_cache
    FROM    pg_statio_user_indexes
    ) a
WHERE   (from_disk + from_cache) > 0
),
indexes as
(
SELECT  *
FROM    (
    SELECT  indexrelname as index_name,
        coalesce(idx_blks_read,0) as from_disk,
        coalesce(idx_blks_hit,0) as from_cache
    FROM    pg_statio_user_indexes
    ) a
WHERE   (from_disk + from_cache) > 0
)
SELECT index_name as "index name",
    from_disk as "disk hits",
    round((from_disk::numeric / (from_disk + from_cache)::numeric)*100.0,2) as "% disk hits",
    round((from_cache::numeric / (from_disk + from_cache)::numeric)*100.0,2) as "% cache hits",
    (from_disk + from_cache) as "total hits"
FROM    (SELECT * FROM all_indexes UNION ALL SELECT * FROM indexes) a
WHERE index_name not like '%_toast_%'
ORDER   BY (case when index_name = 'all' then 0 else 1 end), from_disk desc ;
