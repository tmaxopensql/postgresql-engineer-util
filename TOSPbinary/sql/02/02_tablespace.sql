select
        oid AS "TABLESPACE OID",
        spcname AS "Tablespace name",
        pg_catalog.pg_get_userbyid(spcowner) AS "TABLESPACE OWNER",
	pg_size_pretty(pg_tablespace_size(spcname)) as "TABLESPACE SIZE",
        case
       		when spcname='pg_default' then :v1
        	when spcname='pg_global' then :v2
        	else pg_catalog.pg_tablespace_location(oid)
        end AS "LOCATION"
FROM
        pg_catalog.pg_tablespace
ORDER BY 1;
