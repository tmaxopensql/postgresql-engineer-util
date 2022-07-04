select 'query : update testtb set col2=$1; ' as executed_query ;	explain analyze update testtb set col2=$1;
select 'query : select * from pg_stat_database_conflicts; ' as executed_query ;	explain analyze select * from pg_stat_database_conflicts;
select 'query : select * from pg_stat_all_tables; ' as executed_query ;	explain analyze select * from pg_stat_all_tables;
select 'query : select datname, xact_commit, xact_rollback from pg_stat_database; ' as executed_query ;	explain analyze select datname, xact_commit, xact_rollback from pg_stat_database;
select 'query : select schemaname, relname, seq_scan, idx_scan, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from pg_stat_user_tables; ' as executed_query ;	explain analyze select schemaname, relname, seq_scan, idx_scan, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from pg_stat_user_tables;
select 'query : select n_mod_since_analyze, n_ins_since_vacuum from pg_stat_user_tables; ' as executed_query ;	explain analyze select n_mod_since_analyze, n_ins_since_vacuum from pg_stat_user_tables;
select 'query : select xact_commit, xact_rollback from pg_stat_database; ' as executed_query ;	explain analyze select xact_commit, xact_rollback from pg_stat_database;
select 'query : select schemaname, relname, seq_scan, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from pg_stat_user_tables; ' as executed_query ;	explain analyze select schemaname, relname, seq_scan, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from pg_stat_user_tables;
select 'query : select n_live_tup , n_dead_tup from pg_stat_user_tables; ' as executed_query ;	explain analyze select n_live_tup , n_dead_tup from pg_stat_user_tables;
select 'query : select schemaname, relname, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from  pg_stat_user_tables; ' as executed_query ;	explain analyze select schemaname, relname, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd from  pg_stat_user_tables;