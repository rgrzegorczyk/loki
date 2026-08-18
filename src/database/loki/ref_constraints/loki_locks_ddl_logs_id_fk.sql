alter table loki.loki_locks
    add constraint loki_locks_ddl_logs_id_fk
        foreign key ( ddl_log_id )
            references loki.loki_ddl_logs ( ddl_log_id )
                on delete set null
        enable;


-- sqlcl_snapshot {"hash":"4959a1aa0694ab7dd7610debad35f856bcffd231","type":"REF_CONSTRAINT","name":"LOKI_LOCKS_DDL_LOGS_ID_FK","schemaName":"LOKI","sxml":""}