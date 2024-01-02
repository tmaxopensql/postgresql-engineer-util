begin;

create extension if not exists pg_stat_statements;

select
	a.queryid,
        b.usename,
        c.datname,
        a.query,
	a.plans as planed_counts,
	a.calls as call_counts
from
     pg_stat_statements a
join pg_user b on a.userid = b.usesysid
join pg_stat_database c on a.dbid = c.datid
where
        c.datname = :v1 and a.queryid = :v2 ;

select
	a.total_plan_time,
	a.min_plan_time,
	a.max_plan_time,
        a.total_exec_time,
        a.min_exec_time,
        a.max_exec_time
from
     pg_stat_statements a
join pg_user b on a.userid = b.usesysid
join pg_stat_database c on a.dbid = c.datid
where
        c.datname = :v1 and a.queryid = :v2 ;


--lock check
SELECT
  	sa.pid,
  	sa.state,
  	sa.wait_event_type,
  	sa.wait_event,
  	pl.locktype,
  	pl.mode
FROM
  pg_stat_activity AS sa
  LEFT JOIN pg_locks AS pl ON sa.pid = pl.pid
WHERE
  sa.datname = :v1 and sa.query_id = :v2 ;

select pg_sleep(5);


end;

