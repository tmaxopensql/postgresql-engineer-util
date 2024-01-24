select 
        s.usename as "ROLE", 
        d.datname as "DATABASE NAME", 
        pg_encoding_to_char(d.encoding) as "ENCODING", 
        d.datcollate as "COLATE", 
        d.datctype as "CTYPE", 
        d.datacl as "ACL_AUTH"
from 
        pg_database d, pg_shadow s
where 
        s.usesysid = d.datdba;

select
        usename as "ROLE LIST",
        usesysid as "ROLE OID",
        usecreatedb as "CREATEDB",
        usesuper as "SUPERUSER",
        userepl as "REPLICAION",
        usebypassrls as "BYPASSRLS"
from 
        pg_shadow;
