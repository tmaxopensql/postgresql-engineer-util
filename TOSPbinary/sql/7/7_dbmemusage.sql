begin;

create extension pg_buffercache;

with
pg_total as
(
SELECT
        *
FROM (
SELECT
        'pg_total_buffer' AS database_name,
        pg_size_pretty(count(*) * current_setting('block_size')::integer) AS shared_memory_size,
        round(100.0 * (count(*) * current_setting('block_size')::numeric) / (count(*) * current_setting('block_size')::numeric),2) as percent_of_pgbuffer
FROM pg_buffercache
)a),
databases as
(
SELECT d.datname AS database_name,
       pg_size_pretty(count(*) * current_setting('block_size')::integer) AS shared_memory_size,
       round(100.0 * (count(*) * current_setting('block_size')::numeric)/(select setting::integer * current_setting('block_size')::numeric from pg_settings where name='shared_buffers'),2) as percent_of_pgbuffer 
FROM pg_buffercache b
  INNER JOIN pg_database d ON b.reldatabase = d.oid
GROUP BY d.datname
)
select 
	database_name,
	shared_memory_size,
	percent_of_pgbuffer
from
(
	select * 
	from pg_total
	union all
	select * from databases) a
order by percent_of_pgbuffer desc
;

select pg_sleep(5);

drop extension pg_buffercache;

end;
