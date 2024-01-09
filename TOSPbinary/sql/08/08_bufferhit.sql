/*<database hit(buffercache hit)>*/
SELECT 
 	'buffer cache' as hit_object,
  	coalesce(sum(blks_read),0) as "Database Disk Read",
  	coalesce(sum(blks_hit),0) as "Database Cache Hit",
  	coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0)||'%' as "Buffer Cache Hit Ratio",
  	CASE WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 95.00 then 'Very Good'
	     WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 85.00 and coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) < 95.00 then 'Good'
	     WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 75.00 and coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) < 85.00 then 'Average'
	     WHEN coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) >= 65.00 and coalesce(round(sum(blks_hit)*100/sum(blks_hit + blks_read),2),0) < 75.00 then 'Bad'
       	     WHEN coalesce(sum(blks_read),0) = 0 and coalesce(sum(blks_hit),0)=0 then 'Not Work'
             ELSE 'Very Bad' END AS "CHECK"
FROM
  	pg_stat_database
WHERE
  	datname = :v1 and blks_read > 0 and blks_hit > 0;
