select 
	s.usename as owner,
	t.spcname as tablespace_name,
	d.datname as database_name,
	pg_tablespace_location(t.oid) as tablespace_directory, 
	pg_size_pretty(pg_tablespace_size(spcname)) as tablespace_size
from 
	pg_tablespace t, pg_shadow s, pg_database d
where 
	t.spcowner = s.usesysid and d.dattablespace = t.oid and s.usename = :v1;
