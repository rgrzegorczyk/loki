-- Hide developer tools
begin
  apex_application_admin.set_application_status(
    p_application_id      => apex_application_install.get_application_id,
    p_application_status  => apex_application_admin.c_app_available
  );
end;
/