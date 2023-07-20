select 
	oid AS OID,
	spcname AS "Tablespace name",
	pg_catalog.pg_get_userbyid(spcowner) AS "Owner",
	case
	when spcname='pg_default' then :v1
	when spcname='pg_global' then :v2
	else pg_catalog.pg_tablespace_location(oid) 
	end AS "Location",
	pg_size_pretty(pg_tablespace_size(spcname)) as tablespace_size
FROM
 	pg_catalog.pg_tablespace
ORDER BY 1;
