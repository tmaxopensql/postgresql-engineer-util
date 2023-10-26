SELECT 
    	c.relnamespace::regnamespace as schema_name,
    	c.relname as table_name,
    	greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as txid_age,
    	2^31 - 1000000 - greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as remain_transaction_count,
    	case when (2^31 - greatest(age(c.relfrozenxid),age(t.relfrozenxid))) < 1000000 then 'TRANSACTION LEFT UNDER 1000000!! MUST DO VACUUM'
	     when (2^31 - greatest(age(c.relfrozenxid),age(t.relfrozenxid))) > 1000000 and (2^31 - greatest(age(c.relfrozenxid),age(t.relfrozenxid))) <= 2000000 then 'TRANSACTION LEFT NEAR 1000000!'
	else 'NORMAL STATE' end as message
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind IN ('r', 'm' ,'p')
and c.relnamespace not in('11', '13235')
ORDER BY 4
limit 10;
