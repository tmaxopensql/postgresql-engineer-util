/*<database hit(buffercache hit)>*/
SELECT 
 	'database I/O' as hit_object,
  	coalesce(sum(blks_read),0) as "Database Disk Read",
  	coalesce(sum(blks_hit),0) as "Database Cache Hit",
  	coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0)||'%' as "Buffer Cache Hit Ratio",
  	CASE WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 90.00 then 'Good'
       	     WHEN coalesce(sum(blks_read),0) = 0 and coalesce(sum(blks_hit),0)=0 then 'Not Work'
             ELSE 'Bad' END AS "CHECK"
FROM
  	pg_stat_database
WHERE
  	datname = :v1;

/*<table hit>*/
SELECT 
	'table I/O' as hit_object,
  	coalesce(sum(heap_blks_read),0) as "Table Disk Read",
  	coalesce(sum(heap_blks_hit),0) as "Table Cache Hit",
  	coalesce(round(sum(heap_blks_hit)*100 / sum(heap_blks_hit + heap_blks_read),2),0)||'%' as "Table Cache Hit Ratio",
  	CASE WHEN coalesce(round(sum(heap_blks_hit)*100/sum(heap_blks_hit + heap_blks_read),2),0) >= 90.00 then 'Good'
             WHEN coalesce(sum(heap_blks_read),0) = 0 and coalesce(sum(heap_blks_hit),0) = 0 then 'Not Work'
             ELSE 'Bad' END AS "CHECK"
FROM
  	pg_statio_user_tables;

/*<index hit>*/
SELECT 
	'index I/O' as hit_object,
  	coalesce(sum(idx_blks_read),0) as "Idx Disk Read",
  	coalesce(sum(idx_blks_hit),0)  as "Idx Cache Hit",
  	coalesce(round(sum(idx_blks_hit)*100/ sum(idx_blks_hit + idx_blks_read),2),0)||'%' as "Idx Hit Ratio",
  	CASE WHEN coalesce(round(sum(idx_blks_hit)*100/sum(idx_blks_hit + idx_blks_read),2),0) >= 90.00 then 'Good'
       	     WHEN coalesce(sum(idx_blks_read),0) = 0 and coalesce(sum(idx_blks_hit),0) = 0 then 'Not Work'
       	     ELSE 'Bad' END AS "CHECK"
FROM
  	pg_statio_user_indexes;

/*<sequence hit>*/
SELECT 
	'sequence I/O' as hit_object,
  	coalesce(sum(blks_read),0) as "Sequence Disk Read",
  	coalesce(sum(blks_hit),0) as "Sequence Cache Hit",
  	coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0)||'%' as "Sequence Hit Ratio",
  	CASE WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 90.00 then 'Good'
       	     WHEN coalesce(sum(blks_read),0) = 0 and coalesce(sum(blks_hit),0)=0 then 'Not Work'
       	     ELSE 'Bad' END AS "CHECK"
FROM
  	pg_statio_user_sequences;

/*<slru(simple least-recently-used)>*/
SELECT 
	'slru I/O' as hit_object,
  	coalesce(sum(blks_read),0) as "SLRU Disk Read",
  	coalesce(sum(blks_hit),0) as "SLRU Cache Hit",
  	coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0)||'%' as "SLRU Hit Ratio",
  	CASE WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 90.00 then 'Good'
       	     WHEN coalesce(sum(blks_read),0) = 0 and coalesce(sum(blks_hit),0)=0 then 'Not Work'
       	     ELSE 'Bad' END AS "CHECK"
FROM
  	pg_stat_slru;
