declare
    l_valid_count pls_integer;
begin
    select count(*)
    into l_valid_count
    from user_objects
    where object_name in ('LOKI_UTIL', 'LOKI_LOCK')
      and object_type in ('PACKAGE', 'PACKAGE BODY')
      and status = 'VALID';

    if l_valid_count <> 4 then
        raise_application_error(
            -20119,
            'A patched package is missing or invalid. Query USER_ERRORS; settings and jobs were not changed.'
        );
    end if;

    dbms_output.put_line('Patched package specifications and bodies are VALID.');
end;
/
