alter table loki.loki_locks
    add constraint loki_locks_user_id_fk
        foreign key ( user_id )
            references loki.loki_users ( user_id )
                on delete cascade
        enable;


-- sqlcl_snapshot {"hash":"d8d7f1576db59640ee3e169a43c3c23d667fd58d","type":"REF_CONSTRAINT","name":"LOKI_LOCKS_USER_ID_FK","schemaName":"LOKI","sxml":""}