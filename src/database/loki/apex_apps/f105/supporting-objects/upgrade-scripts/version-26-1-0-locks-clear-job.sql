begin
    begin
        dbms_scheduler.drop_job(
            job_name => 'LOKI.LOKI_LOCKS_CLEAR',
            force    => true
        );
    exception
        when others then
            if sqlcode != -27475 then
                raise;
            end if;
    end;

    dbms_scheduler.create_job(
        job_name            => 'LOKI.LOKI_LOCKS_CLEAR',
        job_type            => 'PLSQL_BLOCK',
        job_action          => 'BEGIN
  LOKI_LOCK.CLEAR_LOCKS(LOKI_UTIL.GET_SETTINGS().LOCKS_RETENTION_HOURS);
  COMMIT;
END;',
        start_date          => timestamp '2022-01-01 01:00:00.0',
        repeat_interval     => 'FREQ=HOURLY;INTERVAL=1',
        end_date            => null,
        job_class           => 'DEFAULT_JOB_CLASS',
        comments            => null,
        auto_drop           => false,
        number_of_arguments => 0
    );

    dbms_scheduler.set_attribute(
        name      => 'LOKI.LOKI_LOCKS_CLEAR',
        attribute => 'logging_level',
        value     => dbms_scheduler.logging_off
    );

    dbms_scheduler.set_attribute(
        name      => 'LOKI.LOKI_LOCKS_CLEAR',
        attribute => 'job_priority',
        value     => 3
    );

    dbms_scheduler.enable('LOKI.LOKI_LOCKS_CLEAR');
end;
/


-- sqlcl_snapshot {"hash":"6f216854ab4b840edb3ae5c0208163aeba508b32","type":"JOB","name":"LOKI_LOCKS_CLEAR","schemaName":"LOKI","sxml":""}