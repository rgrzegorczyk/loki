create table loki.loki_lock_exclusions (
    schema_name varchar2(255 byte) not null enable,
    object_type varchar2(255 byte) not null enable,
    object_name varchar2(255 byte) not null enable,
    reason      varchar2(1000 byte),
    created     timestamp(6) with local time zone default on null localtimestamp not null enable,
    created_by  varchar2(255 byte) default on null coalesce(
        sys_context('APEX$SESSION', 'APP_USER'),
        sys_context('USERENV', 'PROXY_USER'),
        user
    ) not null enable
);

alter table loki.loki_lock_exclusions
    add constraint loki_lock_exclusions_pk primary key (
        schema_name,
        object_type,
        object_name
    ) using index enable;

