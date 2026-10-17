set serveroutput on
set verify off
whenever sqlerror exit sql.sqlcode rollback

prompt Installing LOKI_RESOLVER in the protected application schema...

declare
begin
    if sys_context('USERENV', 'SESSION_USER') = 'LOKI' then
        raise_application_error(
            -20110,
            'Run this script as the protected application schema owner, not as LOKI.'
        );
    end if;
end;
/

@@../project/src/app_schema/loki_resolver.sql

declare
    l_valid_count pls_integer;
    l_grant_count pls_integer;
begin
    select count(*)
    into l_valid_count
    from user_objects
    where object_name = 'LOKI_RESOLVER'
      and object_type in ('PACKAGE', 'PACKAGE BODY')
      and status = 'VALID';

    select count(*)
    into l_grant_count
    from user_tab_privs_made
    where table_name = 'LOKI_RESOLVER'
      and grantee = 'LOKI'
      and privilege = 'EXECUTE';

    if l_valid_count <> 2 then
        raise_application_error(
            -20111,
            'LOKI_RESOLVER specification or body is missing or invalid. Query USER_ERRORS for details.'
        );
    end if;

    if l_grant_count = 0 then
        raise_application_error(
            -20112,
            'The direct EXECUTE grant on LOKI_RESOLVER to LOKI is missing.'
        );
    end if;

    dbms_output.put_line(
        'LOKI_RESOLVER is valid in schema '
        || sys_context('USERENV', 'SESSION_USER')
        || ' and EXECUTE is granted to LOKI.'
    );
end;
/

whenever sqlerror continue none
