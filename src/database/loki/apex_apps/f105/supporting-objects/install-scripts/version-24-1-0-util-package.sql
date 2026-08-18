create or replace package loki_util as
  -- CONSTANTS
  c_yes constant varchar2(1) := 'Y';
  c_no constant varchar2(1) := 'N';
  c_default_time_zone constant varchar2(10) := 'UTC';
  c_default_date_time_format constant varchar2(30) := 'YYYY/MM/DD HH:MI:SS PM';

  -- TYPES
  type r_settings_type is record (
    locks_log_retention_months  pls_integer,
    ddl_log_retention_months    pls_integer,
    first_run                   varchar2(1)
  );

  -- ASSERT
  procedure assert (
    i_condition in boolean,
    i_message   in varchar2
  );

  -- SETTINGS
  function get_settings return r_settings_type result_cache;
  procedure set_settings(i_settings r_settings_type);

  -- USERS
  function get_user(i_user_id loki_users.user_id%type) return loki_users%rowtype;
  function get_current_user return loki_users%rowtype;
  function get_session_user return varchar2;
  function is_admin return boolean;
  function session_user_is_dba return boolean;
end;
/

create or replace package body loki_util as
  -- ASSERT
  procedure assert (
    i_condition in boolean,
    i_message   in varchar2
  ) as
  begin
    if not i_condition or i_condition is null then
      raise_application_error(
                             -20000,
                             i_message
      );
    end if;
  end assert;

  -- SETTINGS
  function get_settings return r_settings_type result_cache is
    l_clob          clob;
    l_settings_json json_object_t;
    l_settings      r_settings_type;
  begin
    begin
      select json_content
        into l_clob
        from loki_settings;

      l_settings_json := json_object_t(l_clob);
      l_settings.locks_log_retention_months 
        := coalesce(l_settings_json.get_number('locks_log_retention_months'), 3);
      l_settings.ddl_log_retention_months 
        := coalesce(l_settings_json.get_number('ddl_log_retention_months'), 3);
      l_settings.first_run 
        := coalesce(l_settings_json.get_string('first_run'), c_yes);
    end;

    return l_settings;
  end get_settings;

  procedure set_settings(i_settings r_settings_type) is
    l_settings_json json_object_t := json_object_t();
    l_settings_clob clob;
  begin
    assert(
      i_condition => i_settings.locks_log_retention_months >= 0,
      i_message   => 'LOKI: Locks log retention months should be a positive number'
    );

    assert(
      i_condition => i_settings.ddl_log_retention_months >= 0,
      i_message   => 'LOKI: DDL log retention months should be a positive number'
    );

    assert(
      i_condition => i_settings.first_run is not null,
      i_message   => 'LOKI: first run should be a varchar2 (Y, N)'
    );

    l_settings_json.put(
      'locks_log_retention_months', 
      i_settings.locks_log_retention_months
    );
    l_settings_json.put(
      'ddl_log_retention_months', 
      i_settings.ddl_log_retention_months
    );
    l_settings_json.put(
      'first_run', 
      i_settings.first_run
    );
    l_settings_clob := l_settings_json.to_clob();

    update loki_settings
       set json_content = l_settings_clob;
  end set_settings;

  -- USERS
  function get_user(i_user_id loki_users.user_id%type) return loki_users%rowtype as
    l_loki_user loki_users%rowtype;
  begin
    select *
      into l_loki_user
      from loki_users
     where user_id = i_user_id;

    return l_loki_user;
  end get_user;

  function get_current_user return loki_users%rowtype as
    l_loki_user loki_users%rowtype;
    l_apex_user loki_users.apex_username%type;
    l_db_user   loki_users.db_username%type;
  begin
    l_apex_user := upper(sys_context(
                                    'APEX$SESSION',
                                    'APP_USER'
                         ));
    l_db_user   := coalesce(
                         sys_context(
                                    'USERENV',
                                    'PROXY_USER'
                         ),
                         user
                 );
    select *
      into l_loki_user
      from loki_users
     where ( l_apex_user is not null
       and apex_username = l_apex_user )
        or ( l_apex_user is null
       and db_username = l_db_user );

    return l_loki_user;
  exception
    when no_data_found then
      return null;
  end get_current_user;

  function get_session_user return varchar2 is
  begin
    return substr(
      coalesce(
        sys_context(
          'APEX$SESSION',
          'APP_USER'
        ),
        sys_context(
          'USERENV',
          'PROXY_USER'
        ),
        user
      ),
      1,
      255
    );
  end get_session_user;

  function is_admin return boolean is
    l_retval       boolean;
    l_current_user loki_users%rowtype;
  begin
    l_current_user := get_current_user();
    if l_current_user.user_id is null then
      l_retval := false;
    else
      l_retval :=
        l_current_user.active_yn = c_yes
        and l_current_user.admin_yn = c_yes;
    end if;

    return l_retval;
  end is_admin;

  function session_user_is_dba return boolean is
    l_check pls_integer;
  begin
    select 1
      into l_check
      from user_role_privs
     where granted_role in ('DBA', 'PDB_DBA');

    return true;
  exception when no_data_found then
    return false;
  end session_user_is_dba;
end loki_util;
/