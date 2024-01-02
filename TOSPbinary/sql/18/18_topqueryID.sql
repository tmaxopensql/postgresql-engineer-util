/* total top 10 query*/

begin;

create extension if not exists pg_stat_statements;


select 
	b.usename, 
	c.datname, 
	a.queryid,
	substr(a.query,1,50) as query_simple
from 
	public.pg_stat_statements a
join pg_catalog.pg_user b on a.userid = b.usesysid
join pg_catalog.pg_stat_database c on a.dbid = c.datid
where 
	c.datname = :v1
order by a.max_exec_time desc
limit 10;

select pg_sleep(5);

end;
