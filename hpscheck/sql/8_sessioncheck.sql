/* session check */
select 
	pid as process_id, 
	usename as owner,
	datname as dbname,
	application_name as application_name,
	client_addr || ':' || client_port as ip_port_info,
	to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS') as session_started_time,
	to_char(state_change, 'YYYY-MM-DD HH24:MI:SS') as session_changed_time,
	state as current_status,
	--substr(query,1,100) as query,
	wait_event_type as wait_type,
	wait_event as wait,
	backend_type
from 
	pg_stat_activity;
