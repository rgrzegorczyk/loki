declare
  l_fullname      loki_users.full_name%type;
  l_apex_username loki_users.apex_username%type;
  l_db_username   loki_users.db_username%type;
begin
  l_db_username := coalesce(
    sys_context(
      'USERENV',
      'PROXY_USER'
    ),
    user
  );

  l_fullname := coalesce(
    sys_context(
      'APEX$SESSION',
      'APP_USER'
    ),
    l_db_username
  );

  l_apex_username := coalesce(
    sys_context(
      'APEX$SESSION',
      'APP_USER'
    ),
    l_db_username
  );

  insert into loki_users (
    full_name,
    apex_username,
    db_username,
    admin_yn,
    active_yn,
    time_zone,
    date_time_format
  ) values (
    l_fullname,
    l_apex_username,
    l_db_username,
    'Y',
    'Y',
    'UTC',
    'YYYY/MM/DD HH24:MI:SS'
  );
end;
/
