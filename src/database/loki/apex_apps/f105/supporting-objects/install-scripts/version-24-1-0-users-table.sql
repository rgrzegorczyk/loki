create table loki_users (
  user_id          number default on null to_number(sys_guid(),
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') not null,
  full_name        varchar2(255) not null,
  apex_username    varchar2(255) not null,
  db_username      varchar2(255),
  admin_yn         varchar2(1) default 'N' not null,
  active_yn        varchar2(1) default on null 'Y' not null,
  created          timestamp(6) with local time zone default on null localtimestamp not null,
  created_by       varchar2(255) default on null coalesce(
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
  updated          timestamp(6) with local time zone,
  updated_by       varchar2(255),
  time_zone        varchar2(255) not null,
  date_time_format varchar2(255) not null
);
alter table loki_users
  add check ( admin_yn in ( 'Y',
                            'N' ) );
alter table loki_users
  add check ( active_yn in ( 'Y',
                             'N' ) );
alter table loki_users add constraint loki_users_pk primary key ( user_id )
  using index;
alter table loki_users add constraint loki_users_db_user_uk unique ( db_username )
  using index;
alter table loki_users add constraint loki_users_apex_user_uk unique ( apex_username )
  using index;