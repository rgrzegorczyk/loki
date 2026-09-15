create table loki_object_types (
  object_type_id            number default to_number(sys_guid(),
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
  loki_object_type          varchar2(255),
  dbms_metadata_object_type varchar2(255),
  ora_dict_obj_type         varchar2(255),
  dba_objects_object_type   varchar2(255),
  loki_locking_type         varchar2(20),
  row_version               number default 1 not null,
  created                   timestamp(6) with local time zone default localtimestamp not null,
  created_by                varchar2(255) default on null coalesce(
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
  updated                   timestamp(6) with local time zone,
  updated_by                varchar2(255)
);
alter table loki_object_types add constraint loki_object_types_pk primary key ( object_type_id )
  using index;
alter table loki_object_types add constraint loki_object_types_u1 unique ( loki_object_type )
  using index;
alter table loki_object_types add constraint loki_object_types_u2 unique ( dbms_metadata_object_type )
  using index;
alter table loki_object_types
  add constraint loki_object_types_ck
    check ( loki_locking_type in ( 'NONE',
                                   'DIRECT',
                                   'ESCALATED',
                                   'MIXED' ) );

insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'PACKAGE',
  'PACKAGE',
  null,
  'PACKAGE',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'TYPE',
  'TYPE',
  null,
  'TYPE',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'MATERIALIZED_VIEW_LOG',
  'MATERIALIZED_VIEW_LOG',
  'SNAPSHOT LOG',
  null,
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'PACKAGE_BODY',
  'PACKAGE_BODY',
  'PACKAGE BODY',
  'PACKAGE BODY',
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'TYPE_BODY',
  'TYPE_BODY',
  'TYPE BODY',
  'TYPE BODY',
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'AQ_QUEUE_TABLE',
  'AQ_QUEUE_TABLE',
  null,
  'TABLE',
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'COMMENT',
  'COMMENT',
  '{BASE_OBJECT_TYPE}',
  null,
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'CONTEXT',
  'CONTEXT',
  'CONTEXT',
  'CONTEXT',
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'INDEX',
  'INDEX',
  'INDEX',
  'INDEX',
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'MATERIALIZED_VIEW',
  'MATERIALIZED_VIEW',
  'SNAPSHOT',
  'MATERIALIZED VIEW',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'OBJECT_GRANT',
  'OBJECT_GRANT',
  'OBJECT PRIVILEGE',
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'PACKAGE_SPEC',
  'PACKAGE_SPEC',
  'PACKAGE',
  'PACKAGE',
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'PROCEDURE',
  'PROCEDURE',
  'PROCEDURE',
  'PROCEDURE',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'REF_CONSTRAINT',
  'REF_CONSTRAINT',
  '{BASE_OBJECT_TYPE}',
  null,
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'SEQUENCE',
  'SEQUENCE',
  'SEQUENCE',
  'SEQUENCE',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'TABLE',
  'TABLE',
  'TABLE',
  'TABLE',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'VIEW',
  'VIEW',
  'VIEW',
  'VIEW',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'USER',
  'USER',
  'USER',
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'CONSTRAINT',
  'CONSTRAINT',
  '{BASE_OBJECT_TYPE}',
  null,
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'DIRECTORY',
  'DIRECTORY',
  'DIRECTORY',
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'FUNCTION',
  'FUNCTION',
  'FUNCTION',
  'FUNCTION',
  'DIRECT'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'ROLE',
  'ROLE',
  'ROLE',
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'SYSTEM_GRANT',
  'SYSTEM_GRANT',
  'SYSTEM PRIVILEGE',
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'TRIGGER',
  'TRIGGER',
  'TRIGGER',
  'TRIGGER',
  'MIXED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'TYPE_SPEC',
  'TYPE_SPEC',
  'TYPE',
  'TYPE',
  'ESCALATED'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'AQ_QUEUE',
  'AQ_QUEUE',
  null,
  'QUEUE',
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'AQ_TRANSFORMATION',
  'AQ_TRANSFORMATION',
  null,
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'ROLE_GRANT',
  'ROLE_GRANT',
  'ROLE PRIVILEGE',
  null,
  'NONE'
);
insert into loki_object_types (
  loki_object_type,
  dbms_metadata_object_type,
  ora_dict_obj_type,
  dba_objects_object_type,
  loki_locking_type
) values (
  'SYNONYM',
  'SYNONYM',
  'SYNONYM',
  'SYNONYM',
  'DIRECT'
);
commit;