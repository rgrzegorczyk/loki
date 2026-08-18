create index loki.loki_locks_logs_user_id_fk_idx on
    loki.loki_locks_logs (
        user_id
    );


-- sqlcl_snapshot {"hash":"76271eb888cd62f18cd5ad6bc07fff62b72ae071","type":"INDEX","name":"LOKI_LOCKS_LOGS_USER_ID_FK_IDX","schemaName":"LOKI","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>LOKI</SCHEMA>\n   <NAME>LOKI_LOCKS_LOGS_USER_ID_FK_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>LOKI</SCHEMA>\n         <NAME>LOKI_LOCKS_LOGS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>USER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      \n   </TABLE_INDEX>\n</INDEX>"}