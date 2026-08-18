alter table loki.loki_locks_logs
    add constraint loki_locks_logs_ddl_logs_id_fk
        foreign key ( ddl_log_id )
            references loki.loki_ddl_logs ( ddl_log_id )
                on delete set null
        enable;


-- sqlcl_snapshot {"hash":"e2e7ef36ea9dcee283a959c8f164c274bc544790","type":"REF_CONSTRAINT","name":"LOKI_LOCKS_LOGS_DDL_LOGS_ID_FK","schemaName":"LOKI","sxml":""}