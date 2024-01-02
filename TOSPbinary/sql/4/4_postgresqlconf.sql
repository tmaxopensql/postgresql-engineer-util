SELECT 
name, 
context, 
unit, 
setting as now_value, 
boot_val as default_value , 
reset_val as if_reset_default_value
FROM pg_settings
where source ='configuration file' and setting != boot_val;
