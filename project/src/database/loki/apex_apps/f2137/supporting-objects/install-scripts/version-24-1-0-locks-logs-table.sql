create table loki_locks_logs (
  locks_log_id number default on null to_number(sys_guid(),
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') not null,
  lock_id      number not null,
  schema_name  varchar2(255) not null,
  object_type  varchar2(255) not null,
  object_name  varchar2(255) not null,
  locked       timestamp(6) with local time zone not null,
  locked_by    varchar2(255) not null,
  released     timestamp(6) with local time zone,
  released_by  varchar2(255),
    locked_ts    timestamp(6) invisible generated always as ( sys_extract_utc(locked) ) virtual,
  user_id      number not null,
  ddl_log_id   number
);
alter table loki_locks_logs add constraint loki_locks_logs_pk primary key ( locks_log_id )
  using index;

alter table loki_locks_logs
  add constraint loki_locks_logs_ddl_logs_id_fk
    foreign key ( ddl_log_id )
      references loki_ddl_logs ( ddl_log_id )
        on delete set null;

alter table loki_locks_logs
  add constraint loki_locks_logs_user_id_fk
    foreign key ( user_id )
      references loki_users ( user_id )
        on delete cascade;