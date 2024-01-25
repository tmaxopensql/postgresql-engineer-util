/* all session check */
SELECT
        pid as "PROCESS ID",
        usename as "ROLE",
        datname as "DATABASE NAME",
        application_name as "APPLICATION NAME",
        client_addr || ':' || client_port as "IP:PORT",
        to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS') as "SESSION START TIME",
        to_char(state_change, 'YYYY-MM-DD HH24:MI:SS') as "SESSION CHANGE TIME",
        state as "STATUS",
        --substr(query,1,100) as query,
        backend_type as "BACKEND TYPE"
FROM
        pg_stat_activity
limit 30;

/* STATUS SESSION CHECK */
SELECT
        pid as "PROCESS ID",
        usename as "ROLE",
        datname as "DATABASE NAME",
        application_name as "APPLICATION NAME",
        client_addr || ':' || client_port as "IP:PORT",
        to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS') as "SESSION START TIME",
        to_char(state_change, 'YYYY-MM-DD HH24:MI:SS') as "SESSION CHANGE TIME",
        state as "STATUS",
        --substr(query,1,100) as query,
        backend_type as "BACKEND TYPE"
FROM
        pg_stat_activity
WHERE
        state = 'active'
ORDER BY
        backend_start
limit 30;
