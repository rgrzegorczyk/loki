begin
  dbms_scheduler.create_job(
                           'LOKI_LOCKS_LOGS_CLEAR',
                           job_type => 'PLSQL_BLOCK',
                           job_action => 'begin
  loki_lock.clear_locks_log(loki_util.get_settings().locks_log_retention_months);
  commit;
end;',
                           number_of_arguments => 0,
                           start_date => to_timestamp_tz('01-JAN-2022 12.00.00.000000000 AM +00:00',
                          'DD-MON-RRRR HH.MI.SSXFF AM TZR',
                          'NLS_DATE_LANGUAGE=english'),
                           repeat_interval => 'FREQ=DAILY;INTERVAL=1',
                           end_date => null,
                           job_class => 'DEFAULT_JOB_CLASS',
                           enabled => false,
                           auto_drop => false,
                           comments => null
  );
  commit;
end;
/