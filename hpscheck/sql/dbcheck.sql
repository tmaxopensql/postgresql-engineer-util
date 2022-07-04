select
	coalesce(max(datname),'0')
from
	pg_stat_database
where 
	datname = :v1;
