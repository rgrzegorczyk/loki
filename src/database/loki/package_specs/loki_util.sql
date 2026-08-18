create or replace package loki.loki_util as
  -- CONSTANTS
    c_yes constant varchar2(1) := 'Y';
    c_no constant varchar2(1) := 'N';
    c_default_time_zone constant varchar2(10) := 'UTC';
    c_default_date_time_format constant varchar2(30) := 'YYYY/MM/DD HH:MI:SS PM';

  -- TYPES
    type r_settings_type is record (
            locks_log_retention_months pls_integer,
            ddl_log_retention_months   pls_integer,
            locks_retention_hours      pls_integer,
            first_run                  varchar2(1)
    );

  -- ASSERT
    procedure assert (
        i_condition in boolean,
        i_message   in varchar2
    );

  -- SETTINGS
    function get_settings return r_settings_type
        result_cache;

    procedure set_settings (
        i_settings r_settings_type
    );

  -- USERS
    function get_user (
        i_user_id loki_users.user_id%type
    ) return loki_users%rowtype;

    function get_current_user return loki_users%rowtype;

    function get_session_user return varchar2;

    function is_admin return boolean;

  -- SYSTEM
    function dba_views_granted return boolean;

end;
/


-- sqlcl_snapshot {"hash":"7a52690b9d7ebdaf956c63ab0c53591d6721613b","type":"PACKAGE_SPEC","name":"LOKI_UTIL","schemaName":"LOKI","sxml":""}