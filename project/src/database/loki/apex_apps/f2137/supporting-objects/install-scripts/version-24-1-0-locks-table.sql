create table loki_locks (
  lock_id     number default on null to_number(sys_guid(),
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') not null,
  schema_name varchar2(255) not null,
  object_type varchar2(255) not null,
  object_name varchar2(255) not null,
  user_id     number not null,
  created     timestamp(6) with local time zone default on null localtimestamp not null,
  created_by  varchar2(255) default on null coalesce(
    sys_context(
      'APEX$SESSION',
      'APP_USER'
    ),
    sys_context(
      'USERENV',
      'PROXY_USER'
    ),
    user
  ) not null,
  updated     timestamp(6) with local time zone,
  updated_by  varchar2(255),
  ddl_log_id  number
);
alter table loki_locks
  add constraint loki_locks_type_name_schema_uk unique ( schema_name,
                                                         object_type,
                                                         object_name )
    using index;
alter table loki_locks add constraint loki_locks_pk primary key ( lock_id )
  using index;

alter table loki_locks
  add constraint loki_locks_ddl_logs_id_fk
    foreign key ( ddl_log_id )
      references loki_ddl_logs ( ddl_log_id )
        on delete set null;

alter table loki_locks
  add constraint loki_locks_user_id_fk
    foreign key ( user_id )
      references loki_users ( user_id )
        on delete cascade;