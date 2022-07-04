/*transaction check*/
select 
	pid as process_id, 
	usename as owner,
	datname as dbname,
	to_char(xact_start, 'YYYY-MM-DD HH24:MI:SS') as tx_started_time,
	to_char(state_change, 'YYYY-MM-DD HH24:MI:SS') as tx_changed_time,
	state as current_status,
	wait_event_type as waiting_type,
	wait_event as wait_event,
	substr(query,1,100) as query 
from 
	pg_stat_activity
where 
	xact_start is not null;
