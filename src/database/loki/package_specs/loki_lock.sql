create or replace package loki.loki_lock as
    type r_lock_user_type is record (
            lock_id loki_locks.lock_id%type,
            user_id loki_locks.user_id%type
    );
    type t_lock_user_type is
        table of r_lock_user_type;
    function object_locked_by (
        i_schema_name loki_locks.schema_name%type,
        i_object_name loki_locks.object_name%type,
        i_object_type loki_locks.object_type%type
    ) return loki_users.user_id%type;

    procedure create_lock (
        io_lock in out nocopy loki_locks%rowtype
    );

    procedure unlock_lock (
        i_lock_id loki_locks.lock_id%type,
        i_user_id loki_locks.user_id%type
    );

    procedure unlock_locks (
        i_locks t_lock_user_type
    );

    procedure transfer_lock (
        i_lock_id loki_locks.lock_id%type,
        i_user_id loki_users.user_id%type
    );

    procedure transfer_locks (
        i_lock_ids   apex_t_number,
        i_to_user_id loki_users.user_id%type
    );

    procedure handle_ddl_event;

    procedure clear_locks_log (
        i_log_retention_months pls_integer
    );

    procedure clear_ddl_log (
        i_log_retention_months pls_integer
    );

    procedure clear_locks (
        i_retention_hours pls_integer
    );

end loki_lock;
/


-- sqlcl_snapshot {"hash":"a40c29c4630a882675255544b9ca65fc6263c3c5","type":"PACKAGE_SPEC","name":"LOKI_LOCK","schemaName":"LOKI","sxml":""}