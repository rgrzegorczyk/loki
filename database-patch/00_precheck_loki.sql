set serveroutput on
set verify off
whenever sqlerror exit sql.sqlcode rollback

prompt Checking the existing Loki 24.1.1 database installation...

declare
    l_count pls_integer;

    procedure assert_object (
        i_object_name in varchar2,
        i_object_type in varchar2
    ) is
    begin
        select count(*)
        into l_count
        from user_objects
        where object_name = i_object_name
          and object_type = i_object_type;

        if l_count = 0 then
            raise_application_error(
                -20100,
                'Required ' || i_object_type || ' ' || i_object_name
                || ' does not exist in schema LOKI.'
            );
        end if;
    end assert_object;
begin
    if sys_context('USERENV', 'SESSION_USER') <> 'LOKI' then
        raise_application_error(
            -20101,
            'Connect directly as the LOKI schema owner before running this script.'
        );
    end if;

    assert_object('LOKI_SETTINGS', 'TABLE');
    assert_object('LOKI_LOCKS', 'TABLE');
    assert_object('LOKI_LOCKS_LOGS', 'TABLE');
    assert_object('LOKI_DDL_LOGS', 'TABLE');
    assert_object('LOKI_UTIL', 'PACKAGE');
    assert_object('LOKI_UTIL', 'PACKAGE BODY');
    assert_object('LOKI_LOCK', 'PACKAGE');
    assert_object('LOKI_LOCK', 'PACKAGE BODY');

    select count(*)
    into l_count
    from loki_settings;

    if l_count <> 1 then
        raise_application_error(
            -20102,
            'Expected exactly one row in LOKI_SETTINGS, found ' || l_count || '.'
        );
    end if;

    select count(*)
    into l_count
    from session_privs
    where privilege = 'CREATE JOB';

    if l_count = 0 then
        raise_application_error(
            -20103,
            'The LOKI session needs CREATE JOB to install LOKI_LOCKS_CLEAR.'
        );
    end if;

    dbms_output.put_line('Precheck passed for schema LOKI.');
end;
/

whenever sqlerror continue none
