SELECT 
name, 
context, 
unit, 
setting, 
boot_val, 
reset_val
FROM pg_settings
where source ='configuration file' and setting != boot_val;
