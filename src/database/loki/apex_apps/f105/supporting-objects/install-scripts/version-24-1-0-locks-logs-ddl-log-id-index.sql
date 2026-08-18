create index loki_locks_logs_ddl_log_id_fk_idx on
  loki_locks_logs (
    ddl_log_id
  );