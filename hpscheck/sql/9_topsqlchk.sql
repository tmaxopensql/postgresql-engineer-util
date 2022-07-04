/* total top 10 query */

select 
	a.userid,
	b.usename, 
	a.dbid, 
	c.datname, 
	a.queryid, 
	substr(a.query, 1, 100) as query, 
	a.calls, 
	a.total_exec_time, 
	a.min_exec_time, 
	a.max_exec_time, 
	a.rows
from 
	public.pg_stat_statements a
join pg_catalog.pg_user b on a.userid = b.usesysid
join pg_catalog.pg_stat_database c on a.dbid = c.datid
where 
	c.datname = :v1
order by a.max_exec_time desc
limit 10;


/* current top 10 query */
