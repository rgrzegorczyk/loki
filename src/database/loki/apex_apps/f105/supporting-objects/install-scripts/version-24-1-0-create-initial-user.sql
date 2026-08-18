declare
  l_fullname      loki_users.full_name%type;
  l_apex_username loki_users.apex_username%type;
begin
  l_fullname := coalesce(
    sys_context(
      'APEX$SESSION',
      'APP_USER'
    ),
    sys_context(
      'USERENV',
      'PROXY_USER'
    ),
    user
  );

  l_apex_username := sys_context(
    'APEX$SESSION',
    'APP_USER'
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
    l_apex_username,
    loki_util.c_yes,
    loki_util.c_yes,
    'UTC',
    'YYYY/MM/DD HH24:MI:SS'
  );
end;