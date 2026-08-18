--this script is very important as supporting objects scripts contains "Enable APEX Automations"
BEGIN
  apex_application_install.set_auto_install_sup_obj (p_auto_install_sup_obj => true);
END;
/

apex import -input src/database/loki/apex_apps/f105 -workspace DEMO -debug