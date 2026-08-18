alter table loki.loki_locks_logs
    add constraint loki_locks_logs_user_id_fk
        foreign key ( user_id )
            references loki.loki_users ( user_id )
                on delete cascade
        enable;


-- sqlcl_snapshot {"hash":"bf339df997c7ba7f9796881ab85f6e4f3e08af50","type":"REF_CONSTRAINT","name":"LOKI_LOCKS_LOGS_USER_ID_FK","schemaName":"LOKI","sxml":""}