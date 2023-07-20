
/* vacuum used - vacuum verbose 'tablename'*/
select 
	relname, 
	last_vacuum, 
	last_autovacuum, 
	vacuum_count, 
	autovacuum_count
from 
	pg_stat_user_tables
order by last_vacuum, last_autovacuum;


/* vacuum analyze command used - vacuum analyze 'tablename'*/
select 
	relname, 
	last_analyze, 
	last_autoanalyze, 
	analyze_count, 
	autoanalyze_count 
from 
	pg_stat_user_tables 
order by last_analyze, last_autoanalyze;

