/*top 10 dml plans*/

/*
copy(
select 
	'select ' || '''' ||'query : ' || a.query || '; ' || '''' || ' as executed_query ;' ,
	'explain analyze ' || a.query || ';'
from 
	public.pg_stat_statements a 
join pg_catalog.pg_user b on a.userid = b.usesysid 
join pg_catalog.pg_stat_database c on a.dbid = c.datid
where 
	c.datname = :v1 and (a.query like 'select%' or a.query like 'update%' or a.query like 'insert%')
order by a.max_exec_time desc
limit 10 
) to '/var/lib/pgsql/check/sql/99_extra.sql';
*/

