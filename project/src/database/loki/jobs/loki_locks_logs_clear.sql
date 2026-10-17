begin
    dbms_scheduler.create_job(
        job_name            => 'LOKI.LOKI_LOCKS_LOGS_CLEAR',
        job_type            => 'PLSQL_BLOCK',
        job_action          => 'BEGIN
  LOKI_LOCK.CLEAR_LOCKS_LOG(LOKI_UTIL.GET_SETTINGS().LOCKS_LOG_RETENTION_MONTHS);
  COMMIT;
END;',
        start_date          => timestamp '2022-01-01 01:00:00.0',
        repeat_interval     => 'FREQ=DAILY;INTERVAL=1',
        end_date            => null,
        job_class           => 'DEFAULT_JOB_CLASS',
        comments            => null,
        auto_drop           => false,
        number_of_arguments => 0
    );

    dbms_scheduler.set_attribute(
        name      => 'LOKI.LOKI_LOCKS_LOGS_CLEAR',
        attribute => 'logging_level',
        value     => dbms_scheduler.logging_off
    );

    dbms_scheduler.set_attribute(
        name      => 'LOKI.LOKI_LOCKS_LOGS_CLEAR',
        attribute => 'job_priority',
        value     => 3
    );

end;
/


-- sqlcl_snapshot {"hash":"1924f5841d9a9519479c044e10e06e353fe5320f","type":"JOB","name":"LOKI_LOCKS_LOGS_CLEAR","schemaName":"LOKI","sxml":""}