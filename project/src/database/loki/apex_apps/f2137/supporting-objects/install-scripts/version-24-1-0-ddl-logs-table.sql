create table loki_ddl_logs (
  ddl_log_id                number default on null to_number(sys_guid(),
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') not null,
  ddl                       clob not null,
  schema_name               varchar2(255) not null,
  object_name               varchar2(255) not null,
  object_type               varchar2(255) not null,
  event                     varchar2(20) not null,
  logged                    timestamp(6) with local time zone default on null localtimestamp not null,
  logged_by_db_user         varchar2(255) default on null user not null,
  logged_by_db_current_user varchar2(255) default on null sys_context(
    'userenv',
    'current_user'
  ) not null,
  logged_by_db_proxy_user   varchar2(255) default sys_context(
    'userenv',
    'proxy_user'
  ),
  logged_by_apex_user       varchar2(255) default sys_context(
    'apex$session',
    'app_user'
  ),
  ddl_preview               varchar2(255)
);
alter table loki_ddl_logs add constraint loki_ddl_logs_pk primary key ( ddl_log_id )
  using index;