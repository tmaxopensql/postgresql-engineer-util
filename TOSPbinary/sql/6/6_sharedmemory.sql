show shared_buffers;

show wal_buffers;

/*CLOG buffers not have parameters*/
select pg_size_pretty(trunc(txid_current()*2/8/8192,0)*8192 + 8192) as clog_buffers;

show max_locks_per_transaction;

show max_pred_locks_per_transaction;
