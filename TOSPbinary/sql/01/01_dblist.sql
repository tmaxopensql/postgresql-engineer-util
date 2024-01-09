select 
	s.usename as owner, 
	d.datname as database_name, 
	pg_encoding_to_char(d.encoding) as encoding, 
	d.datcollate as colate, 
	d.datctype as ctype, 
	d.datacl as acl_auth
from 
	pg_database d, pg_shadow s
where 
	s.usesysid = d.datdba;


select 
	usename as owner_list 
from 
	pg_shadow;
