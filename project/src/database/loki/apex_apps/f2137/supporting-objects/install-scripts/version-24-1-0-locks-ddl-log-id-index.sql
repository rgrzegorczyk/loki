create index loki_locks_ddl_log_id_fk_idx on
  loki_locks (
    ddl_log_id
  );