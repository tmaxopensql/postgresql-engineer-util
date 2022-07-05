select 
	coalesce(max(usename),'0') 
from 
	pg_shadow 
where 
	usename = :v1;
