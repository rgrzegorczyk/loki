declare
    l_enabled          varchar2(5);
    l_job_action       varchar2(4000);
    l_repeat_interval  varchar2(4000);
    l_settings         loki_util.r_settings_type;

    procedure assert_valid (
        i_object_name in varchar2,
        i_object_type in varchar2
    ) is
        l_status user_objects.status%type;
    begin
        select status
        into l_status
        from user_objects
        where object_name = i_object_name
          and object_type = i_object_type;

        if l_status <> 'VALID' then
            raise_application_error(
                -20120,
                i_object_type || ' ' || i_object_name
                || ' is ' || l_status || '. Query USER_ERRORS for details.'
            );
        end if;

        dbms_output.put_line(i_object_type || ' ' || i_object_name || ': VALID');
    end assert_valid;
begin
    assert_valid('LOKI_UTIL', 'PACKAGE');
    assert_valid('LOKI_UTIL', 'PACKAGE BODY');
    assert_valid('LOKI_LOCK', 'PACKAGE');
    assert_valid('LOKI_LOCK', 'PACKAGE BODY');

    l_settings := loki_util.get_settings();
    if l_settings.locks_retention_hours < 0 then
        raise_application_error(
            -20121,
            'locks_retention_hours must be zero or greater.'
        );
    end if;

    dbms_output.put_line(
        'Configured lock retention: '
        || l_settings.locks_retention_hours
        || ' hour(s).'
    );

    select enabled, job_action, repeat_interval
    into l_enabled, l_job_action, l_repeat_interval
    from user_scheduler_jobs
    where job_name = 'LOKI_LOCKS_CLEAR';

    if l_enabled <> 'TRUE' then
        raise_application_error(-20122, 'LOKI_LOCKS_CLEAR is not enabled.');
    end if;

    if coalesce(instr(upper(l_job_action), 'LOKI_LOCK.CLEAR_LOCKS'), 0) = 0 then
        raise_application_error(
            -20123,
            'LOKI_LOCKS_CLEAR does not invoke LOKI_LOCK.CLEAR_LOCKS.'
        );
    end if;

    if coalesce(instr(upper(l_repeat_interval), 'FREQ=HOURLY'), 0) = 0 then
        raise_application_error(
            -20124,
            'LOKI_LOCKS_CLEAR is not scheduled hourly.'
        );
    end if;

    dbms_output.put_line(
        'LOKI_LOCKS_CLEAR: enabled, schedule = ' || l_repeat_interval
    );
end;
/
