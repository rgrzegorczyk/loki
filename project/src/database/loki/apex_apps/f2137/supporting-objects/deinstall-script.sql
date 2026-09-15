begin
  dbms_scheduler.drop_job(job_name => 'LOKI_DDL_LOGS_CLEAR', force => true);
end;
/

begin
  dbms_scheduler.drop_job(job_name => 'LOKI_LOCKS_LOGS_CLEAR', force => true);
end;
/

drop function check_version;

drop package loki_lock;
drop package loki_util;

drop table loki_locks_logs cascade constraints;
drop table loki_locks cascade constraints;
drop table loki_ddl_logs cascade constraints;
drop table loki_object_types cascade constraints;
drop table loki_users cascade constraints;
drop table loki_settings cascade constraints;