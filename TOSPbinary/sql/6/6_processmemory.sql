
select 
	a.setting as autovacuum_work_mem, 
	c.setting as autovacuum_max_workers,
	case when cast(a.setting as integer) = -1 then pg_size_pretty(cast(b.setting as bigint)*1024*cast(c.setting as integer))
	     when cast(a.setting as integer) > 0 then pg_size_pretty(cast(a.setting as bigint)*1024*cast(c.setting as integer)) 
	     when pg_size_pretty(cast(a.setting as bigint)*1024*cast(c.setting as integer)) > pg_size_pretty(1024*1024*1024::bigint) then pg_size_pretty(1024*1024*1024::bigint)
	end as total_autovacuum_buffers
from 
	pg_settings a, pg_settings b , pg_settings c
where 
	a.name = 'autovacuum_work_mem' and b.name = 'maintenance_work_mem' and c.name='autovacuum_max_workers';

show work_mem;

show maintenance_work_mem;

show temp_buffers;
