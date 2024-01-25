/* total top 10 query*/
-- 수정중!! 2024-01-25
BEGIN;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT
        b.usename as "ROLE",
        c.datname as "DATABASE NAME",
        a.queryid as "QUERY ID",
        a.max_exec_time as "MAX EXEC TIME (MS)",
        substr(a.query,1,50) as "SIMPLE QUERY"
FROM
        public.pg_stat_statements a
join pg_catalog.pg_user b on a.userid = b.usesysid
join pg_catalog.pg_stat_database c on a.dbid = c.datid
WHERE
        c.datname = :v1
order by a.max_exec_time desc
limit 10;

SELECT
        b.usename as "ROLE",
        c.datname as "DATABASE NAME",
        a.queryid as "QUERY ID",
        a.local_blks_read as "LOCAL BLOCK READ",
        substr(a.query,1,50) as "SIMPLE QUERY"
FROM
        public.pg_stat_statements a
join pg_catalog.pg_user b on a.userid = b.usesysid
join pg_catalog.pg_stat_database c on a.dbid = c.datid
WHERE
        c.datname = :v1
order by a.local_blks_read desc
limit 10;


select pg_sleep(5);

ROLLBACK;
