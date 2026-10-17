create index loki.loki_locks_logs_ddl_log_id_fk_idx on
    loki.loki_locks_logs (
        ddl_log_id
    );


-- sqlcl_snapshot {"hash":"a50f90ce88f375d2b77131a5df706ffd044f4f48","type":"INDEX","name":"LOKI_LOCKS_LOGS_DDL_LOG_ID_FK_IDX","schemaName":"LOKI","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>LOKI</SCHEMA>\n   <NAME>LOKI_LOCKS_LOGS_DDL_LOG_ID_FK_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>LOKI</SCHEMA>\n         <NAME>LOKI_LOCKS_LOGS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DDL_LOG_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      \n   </TABLE_INDEX>\n</INDEX>"}