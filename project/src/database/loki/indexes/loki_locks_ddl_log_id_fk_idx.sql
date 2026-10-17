create index loki.loki_locks_ddl_log_id_fk_idx on
    loki.loki_locks (
        ddl_log_id
    );


-- sqlcl_snapshot {"hash":"b8b38c9f81c6013926d0f2ea71d8e10611dc22f0","type":"INDEX","name":"LOKI_LOCKS_DDL_LOG_ID_FK_IDX","schemaName":"LOKI","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>LOKI</SCHEMA>\n   <NAME>LOKI_LOCKS_DDL_LOG_ID_FK_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>LOKI</SCHEMA>\n         <NAME>LOKI_LOCKS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DDL_LOG_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      \n   </TABLE_INDEX>\n</INDEX>"}