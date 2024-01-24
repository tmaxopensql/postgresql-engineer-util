SELECT
  name as "Parameter Name",
  context as "Context",
  unit as "Unit",
  setting as "Present Value",
  boot_val as "Default Value",
  reset_val as "Reset Default Value"
FROM pg_settings
where source ='configuration file' and setting != boot_val;
