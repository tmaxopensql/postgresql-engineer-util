begin;

create extension pg_buffercache;
/*
select c.relname as table_name, 
pg_size_pretty(count(*) * 8192) as shared_memory_size
from pg_database d, pg_class c join pg_buffercache b on b.relfilenode=c.relfilenode
where b.reldatabase = d.oid and d.datname = :v1 and c.relname not like 'pg_%'
group by c.relname
order by (count(*) * 8192) desc;
*/

with
db_total as
(
SELECT 'Database_Size' AS relation_name,
       pg_size_pretty(count(*) * current_setting('block_size')::integer) AS shared_memory_size,
       round(100.0 * (count(*) * current_setting('block_size')::numeric) / (count(*) * current_setting('block_size')::numeric),2) as percent_of_table
FROM pg_buffercache b
  INNER JOIN pg_database d ON b.reldatabase = d.oid
where d.datname = :v1
GROUP BY d.datname
),
tables as
(
select  case
	when c.relname like 'pg_%' then 'System Catalog Objects'
	else c.relname 
	end AS relation_name, 
	pg_size_pretty(count(*) * current_setting('block_size')::integer) as shared_memory_size,
	round(100.0 * (count(*) * current_setting('block_size')::numeric) / (SELECT count(*) * current_setting('block_size')::numeric FROM pg_buffercache b INNER JOIN pg_database d ON b.reldatabase = d.oid where d.datname= :v1),2) as percent_of_table
from pg_database d, pg_class c 
join pg_buffercache b on b.relfilenode=c.relfilenode
where b.reldatabase = d.oid and d.datname = :v1 
group by case
	when c.relname like 'pg_%' then 'System Catalog Objects'
	else c.relname
	end
)
select
	relation_name,
	shared_memory_size,
	percent_of_table
from
(
	select *
	from db_total
	union all
	select * from tables) a
order by percent_of_table desc;

select pg_sleep(5);

drop extension pg_buffercache;

end;
