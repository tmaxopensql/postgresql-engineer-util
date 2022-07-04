select 
	datname as database_name, 
	pg_size_pretty(pg_database_size(:v1)) as database_size 
from 
	pg_database 
where 
	datname = :v1
;
