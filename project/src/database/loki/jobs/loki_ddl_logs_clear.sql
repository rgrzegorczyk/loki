begin
    dbms_scheduler.create_job(
        job_name            => 'LOKI.LOKI_DDL_LOGS_CLEAR',
        job_type            => 'PLSQL_BLOCK',
        job_action          => 'BEGIN
  LOKI_LOCK.CLEAR_DDL_LOG(LOKI_UTIL.GET_SETTINGS().DDL_LOG_RETENTION_MONTHS);
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
        name      => 'LOKI.LOKI_DDL_LOGS_CLEAR',
        attribute => 'logging_level',
        value     => dbms_scheduler.logging_off
    );

    dbms_scheduler.set_attribute(
        name      => 'LOKI.LOKI_DDL_LOGS_CLEAR',
        attribute => 'job_priority',
        value     => 3
    );

    dbms_scheduler.enable('LOKI.LOKI_DDL_LOGS_CLEAR');
end;
/


-- sqlcl_snapshot {"hash":"54662f7b69815d1e0099af0d4689e5770d812615","type":"JOB","name":"LOKI_DDL_LOGS_CLEAR","schemaName":"LOKI","sxml":""}