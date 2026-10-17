declare
    l_count   pls_integer;
    l_enabled varchar2(5);
begin
    select count(*)
    into l_count
    from user_scheduler_jobs
    where job_name = 'LOKI_LOCKS_CLEAR';

    if l_count = 0 then
        dbms_scheduler.create_job(
            job_name            => 'LOKI_LOCKS_CLEAR',
            job_type            => 'PLSQL_BLOCK',
            job_action          => 'BEGIN
  LOKI_LOCK.CLEAR_LOCKS(LOKI_UTIL.GET_SETTINGS().LOCKS_RETENTION_HOURS);
  COMMIT;
END;',
            start_date          => systimestamp + interval '1' hour,
            repeat_interval     => 'FREQ=HOURLY;INTERVAL=1',
            end_date            => null,
            job_class           => 'DEFAULT_JOB_CLASS',
            comments            => 'Removes abandoned Loki locks after the configured inactivity period',
            auto_drop           => false,
            enabled             => false
        );

        dbms_scheduler.set_attribute(
            name      => 'LOKI_LOCKS_CLEAR',
            attribute => 'logging_level',
            value     => dbms_scheduler.logging_off
        );

        dbms_scheduler.set_attribute(
            name      => 'LOKI_LOCKS_CLEAR',
            attribute => 'job_priority',
            value     => 3
        );

        dbms_scheduler.enable('LOKI_LOCKS_CLEAR');
        dbms_output.put_line('Created and enabled LOKI_LOCKS_CLEAR.');
    else
        select enabled
        into l_enabled
        from user_scheduler_jobs
        where job_name = 'LOKI_LOCKS_CLEAR';

        if l_enabled = 'FALSE' then
            dbms_scheduler.enable('LOKI_LOCKS_CLEAR');
            dbms_output.put_line('Enabled existing LOKI_LOCKS_CLEAR.');
        else
            dbms_output.put_line('LOKI_LOCKS_CLEAR already exists and is enabled.');
        end if;
    end if;
end;
/
