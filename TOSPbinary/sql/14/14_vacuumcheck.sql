SELECT
        relname as "TABLE",
        schemaname "SCHEMA",
        TO_CHAR(last_vacuum, 'YYYY-MM-DD HH24:MI:SS') as "Last Vacuum Time",
        TO_CHAR(last_autovacuum, 'YYYY-MM-DD HH24:MI:SS') as "Last Autovacuum Time",
        vacuum_count as "Vacuum Count",
        autovacuum_count as "Autovacuum Count"
FROM
        pg_stat_user_tables
ORDER BY last_vacuum, last_autovacuum
LIMIT 20;

SELECT
        relname as "TABLE",
        schemaname "SCHEMA",
        TO_CHAR(last_analyze, 'YYYY-MM-DD HH24:MI:SS') as "Last Analyze Time",
        TO_CHAR(last_autoanalyze, 'YYYY-MM-DD HH24:MI:SS') as "Last Autoanlayze Time",
        analyze_count as "Analyze Count",
        autoanalyze_count as "Autoanalyze Count"
from
        pg_stat_user_tables
order by last_analyze, last_autoanalyze
limit 20;
