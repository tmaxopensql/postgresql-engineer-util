/*
pg_database_size(':v1')
*/
select 
	datname as database_name, 
	pg_size_pretty(pg_database_size(:v1)) as database_size 
from 
	pg_database 
where 
	datname = :v1;


SELECT
        D.datname as "DATABASE NAME",
        pg_size_pretty(pg_database_size(D.datname)) as "DATABASE SIZE"
FROM
        pg_database as D;
