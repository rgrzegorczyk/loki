create table loki.loki_users (
    user_id          number default on null to_number(sys_guid(), 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') not null enable,
    full_name        varchar2(255 byte) not null enable,
    apex_username    varchar2(255 byte) not null enable,
    db_username      varchar2(255 byte),
    admin_yn         varchar2(1 byte) default 'N' not null enable,
    active_yn        varchar2(1 byte) default on null 'Y' not null enable,
    created          timestamp(6) with local time zone default on null localtimestamp not null enable,
    created_by       varchar2(255 byte) default on null coalesce(
        sys_context('APEX$SESSION', 'APP_USER'),
        sys_context('USERENV', 'PROXY_USER'),
        user
    ) not null enable,
    updated          timestamp(6) with local time zone,
    updated_by       varchar2(255 byte),
    time_zone        varchar2(255 byte) not null enable,
    date_time_format varchar2(255 byte) not null enable
);

alter table loki.loki_users
    add
        check ( active_yn in ( 'Y', 'N' ) ) enable;

alter table loki.loki_users
    add
        check ( admin_yn in ( 'Y', 'N' ) ) enable;

alter table loki.loki_users add constraint loki_users_apex_user_uk unique ( apex_username )
    using index enable;

alter table loki.loki_users add constraint loki_users_db_user_uk unique ( db_username )
    using index enable;

alter table loki.loki_users
    add constraint loki_users_pk primary key ( user_id )
        using index enable;


-- sqlcl_snapshot {"hash":"b4969de838953c1bf8cf6831e6b396de2252ad86","type":"TABLE","name":"LOKI_USERS","schemaName":"LOKI","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>LOKI</SCHEMA>\n   <NAME>LOKI_USERS</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>USER_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <DEFAULT_ON_NULL>to_number(sys_guid(),\n          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')</DEFAULT_ON_NULL>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FULL_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>APEX_USERNAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DB_USERNAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ADMIN_YN</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <DEFAULT>'N'</DEFAULT>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACTIVE_YN</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <DEFAULT_ON_NULL>'Y'</DEFAULT_ON_NULL>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREATED</NAME>\n            <DATATYPE>TIMESTAMP_WITH_LOCAL_TIMEZONE</DATATYPE>\n            <SCALE>6</SCALE>\n            <DEFAULT_ON_NULL>localtimestamp</DEFAULT_ON_NULL>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREATED_BY</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <DEFAULT_ON_NULL>coalesce(\n    sys_context(\n      'APEX$SESSION',\n      'APP_USER'\n    ),\n    sys_context(\n      'USERENV',\n      'PROXY_USER'\n    ),\n    user\n  )</DEFAULT_ON_NULL>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>UPDATED</NAME>\n            <DATATYPE>TIMESTAMP_WITH_LOCAL_TIMEZONE</DATATYPE>\n            <SCALE>6</SCALE>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>UPDATED_BY</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TIME_ZONE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DATE_TIME_FORMAT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <NOT_NULL></NOT_NULL>\n            \n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <CHECK_CONSTRAINT_LIST>\n         <CHECK_CONSTRAINT_LIST_ITEM>\n            <CONDITION> admin_yn in ( 'Y',\n                            'N' ) </CONDITION>\n         </CHECK_CONSTRAINT_LIST_ITEM>\n         <CHECK_CONSTRAINT_LIST_ITEM>\n            <CONDITION> active_yn in ( 'Y',\n                             'N' ) </CONDITION>\n         </CHECK_CONSTRAINT_LIST_ITEM>\n      </CHECK_CONSTRAINT_LIST>\n      <PRIMARY_KEY_CONSTRAINT_LIST>\n         <PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>LOKI_USERS_PK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>USER_ID</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n      </PRIMARY_KEY_CONSTRAINT_LIST>\n      <UNIQUE_KEY_CONSTRAINT_LIST>\n         <UNIQUE_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>LOKI_USERS_DB_USER_UK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>DB_USERNAME</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </UNIQUE_KEY_CONSTRAINT_LIST_ITEM>\n         <UNIQUE_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>LOKI_USERS_APEX_USER_UK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>APEX_USERNAME</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </UNIQUE_KEY_CONSTRAINT_LIST_ITEM>\n      </UNIQUE_KEY_CONSTRAINT_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <HEAP_TABLE></HEAP_TABLE>\n      </PHYSICAL_PROPERTIES>\n      \n   </RELATIONAL_TABLE>\n</TABLE>"}