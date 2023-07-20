SELECT 
	datname,
   	age(datfrozenxid) as txid_age,
    	2^31 - 1000000 - age(datfrozenxid) as remain_transaction_count,
	case when (2^31 - age(datfrozenxid)) < 1000000 then 'TRANSACTION LEFT UNDER 1000000!! MUST DO VACUUM'
	     when (2^31 - age(datfrozenxid)) > 1000000 and (2^31 - age(datfrozenxid)) <= 2000000 then 'TRANSACTION LEFT NEAR 1000000!'
	else 'NORMAL STATE' end as message
FROM pg_database
ORDER BY 3;
