select 
	type, 
	database, 
	user_name, 
	address, 
	auth_method 
from 
	pg_hba_file_rules;
