
/* vacuum used - vacuum verbose 'tablename'*/
select
        relname,
        TO_CHAR(last_vacuum, 'YYYY-MM-DD HH24:MI:SS') AS last_vacuum,
        TO_CHAR(last_autovacuum, 'YYYY-MM-DD HH24:MI:SS') AS last_autovacuum,
        vacuum_count,
        autovacuum_count
from
        pg_stat_user_tables
order by last_vacuum, last_autovacuum;


/* vacuum analyze command used - vacuum analyze 'tablename'*/
select
        relname,
        TO_CHAR(last_analyze, 'YYYY-MM-DD HH24:MI:SS') AS last_analyze,
        TO_CHAR(last_autoanalyze, 'YYYY-MM-DD HH24:MI:SS') AS last_autoanalyze,
        analyze_count,
        autoanalyze_count
from
        pg_stat_user_tables
order by last_analyze, last_autoanalyze;


