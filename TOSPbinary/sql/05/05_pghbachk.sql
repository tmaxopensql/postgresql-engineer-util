SELECT
        type as "Type",
        database as "Database",
        user_name as "Role",
        address as "Address",
        auth_method as "Method"
FROM	pg_hba_file_rules;
