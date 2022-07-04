select 
	usename 
from 
	pg_shadow 
where 
	usename = :v1;
