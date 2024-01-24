SELECT
	case when cast(a.setting as integer) = -1 then pg_size_pretty(cast(b.setting as bigint)*1024)
	     when cast(a.setting as integer) > 0 then pg_size_pretty(cast(a.setting as bigint)*1024)
	end as autovacuum_work_mem,
	c.setting as autovacuum_max_workers
FROM 
	pg_settings a, pg_settings b , pg_settings c
WHERE
	a.name = 'autovacuum_work_mem' and b.name = 'maintenance_work_mem' and c.name='autovacuum_max_workers';

show work_mem;

show maintenance_work_mem;

show temp_buffers;
