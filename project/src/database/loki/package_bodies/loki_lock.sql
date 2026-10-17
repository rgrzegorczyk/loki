create or replace package body loki.loki_lock as

    type r_lock_details_type is record (
            event           varchar2(128),
            event_is_rename boolean,
            owner           varchar2(128),
            object_type     loki_locks.object_type%type,
            object_name     loki_locks.object_name%type,
            escalated       boolean default false
    );

    function locking_supported (
        i_ora_dict_obj_type in loki_object_types.ora_dict_obj_type%type
    ) return boolean
        result_cache
    is
        l_ora_dict_obj_type loki_object_types.ora_dict_obj_type%type;
    begin
        select
            ora_dict_obj_type
        into l_ora_dict_obj_type
        from
            loki_object_types
        where
            loki_locking_type in ( 'DIRECT', 'ESCALATED', 'MIXED' )
            and ora_dict_obj_type = i_ora_dict_obj_type;

        return true;
    exception
        when no_data_found then
            return false;
    end locking_supported;

    function get_loki_object_type (
        i_from        in varchar2,
        i_object_type in varchar2
    ) return loki_object_types.loki_object_type%type
        result_cache
    is
        l_loki_object_type loki_object_types.loki_object_type%type;
    begin
        if i_from = 'ORA_DICT_OBJ_TYPE' then
            select
                loki_object_type
            into l_loki_object_type
            from
                loki_object_types
            where
                ora_dict_obj_type = i_object_type;

        elsif i_from = 'DBA_OBJECTS_OBJECT_TYPE' then
            select
                loki_object_type
            into l_loki_object_type
            from
                loki_object_types
            where
                dba_objects_object_type = i_object_type;

        end if;

        return l_loki_object_type;
    exception
        when no_data_found or too_many_rows then
            return i_object_type;
    end get_loki_object_type;

    function get_lock_details (
        i_ddl in clob
    ) return r_lock_details_type is

        type r_object_type is record (
                owner       varchar2(128),
                object_type loki_locks.object_type%type,
                object_name loki_locks.object_name%type
        );
        l_lock_details r_lock_details_type;
        l_object_name  varchar2(128);
        l_rename_re    varchar2(100) := 'rename[[:space:]]+("?[a-z0-9_$#]{1,128}"?[[:space:]]+)?to[[:space:]]+("?[a-z0-9_$#]{1,128}"?)'
        ;

        function ora_sysevent_is_rename return boolean is
        begin
            return ora_sysevent = 'RENAME'
            or (
                ora_sysevent = 'ALTER'
                and ora_dict_obj_type in ( 'TABLE', 'INDEX', 'TRIGGER' )
                and regexp_like(i_ddl, l_rename_re, 'in')
            );
        end;

        function get_new_name return varchar2 is
            l_object_name varchar2(130);
        begin
            l_object_name := regexp_substr(i_ddl, l_rename_re, 1, 1, 'in',
                                           2);
            if substr(l_object_name, 1, 1) = '"' then
                l_object_name := replace(l_object_name, '"', '');
            else
                l_object_name := upper(l_object_name);
            end if;

            return l_object_name;
        end get_new_name;

        procedure escalate_lock is

            l_base_object_rec       r_object_type;
            l_object_type           varchar2(128);
            l_index_base_owner_re   varchar2(255) := 'index[[:space:]]+.*[[:space:]]+on[[:space:]]+(("?[a-z0-9_$#]{1,128}"?)[[:space:]]*\.[[:space:]]*)'
            ;
            l_index_full_re         varchar2(255) := l_index_base_owner_re || '?("?[a-z0-9_$#]{1,128}"?)[[:space:]]*\(';
            l_trigger_base_owner_re varchar2(255) := 'trigger[[:space:]]+.*[insert|update|delete][[:space:]]+.*[[:space:]]+on[[:space:]]+(("?[a-z0-9_$#]{1,128}"?)[[:space:]]*\.[[:space:]]*)'
            ;
            l_trigger_full_re       varchar2(255) := l_trigger_base_owner_re || '?("?[a-z0-9_$#]{1,128}"?).*begin';
            l_trigger_iot_re        varchar2(255) := 'trigger[[:space:]]+.*[[:space:]]+instead[[:space:]]+of[[:space:]]+[insert|update|delete][[:space:]]+.*[[:space:]]+on[[:space:]]+.*[[:space:]]+begin'
            ;
            l_trigger_system_re     varchar2(255) := 'trigger[[:space:]]+.*[[:space:]]+on[[:space:]]+.*[[:space:]]+[database|schema][[:space:]]+begin'
            ;

            function normalize_name (
                i_name in varchar2
            ) return varchar2 is
                l_name varchar2(128);
            begin
                l_name := replace(i_name, '.', '');
                if substr(l_name, 1, 1) = '"' then
                    l_name := replace(l_name, '"', '');
                else
                    l_name := upper(l_name);
                end if;

                return l_name;
            end normalize_name;

        begin
            if l_lock_details.object_type = 'PACKAGE_SPEC' then
                l_lock_details.object_type := 'PACKAGE';
            elsif l_lock_details.object_type = 'PACKAGE_BODY' then
                l_lock_details.object_type := 'PACKAGE';
            elsif l_lock_details.object_type = 'TYPE_SPEC' then
                l_lock_details.object_type := 'TYPE';
            elsif l_lock_details.object_type = 'TYPE_BODY' then
                l_lock_details.object_type := 'TYPE';
            elsif l_lock_details.object_type = 'MATERIALIZED_VIEW_LOG' then
                l_lock_details.object_type := 'TABLE';
            elsif ora_sysevent = 'COMMENT' then
        -- For comments, ora_dict_obj_type is likely either TABLE or COLUMN. The value 
        -- TABLE could actually be a VIEW or MATERIALIZED VIEW so we need to look it up.
        -- In the case of MVIEWS, the backing table is filtered out to get the right type.
        -- If COLUMN, object_name will already be the base object name, se we just need
        -- to look it up.
                select
                    object_type
                into l_object_type
                from
                    all_objects
                where
                        owner = ora_dict_obj_owner
                    and object_name = l_lock_details.object_name
                    and ( object_type != 'TABLE'
                          or object_name not in (
                        select
                            container_name
                        from
                            all_mviews
                        where
                            owner = ora_dict_obj_owner
                    ) );

                l_lock_details.object_type := get_loki_object_type(
                    i_from        => 'DBA_OBJECTS_OBJECT_TYPE',
                    i_object_type => l_object_type
                );
            elsif l_lock_details.object_type = 'INDEX' then
                if ora_sysevent = 'CREATE' then
          -- Currently, only TABLE is supported for the base object during create.
          -- CLUSTER and BITMAP_JOIN_INDEX support can be added later if needed.
                    l_base_object_rec.object_type := 'TABLE';
                    if regexp_instr(i_ddl, l_index_base_owner_re) > 0 then
                        l_base_object_rec.owner := normalize_name(regexp_substr(i_ddl, l_index_full_re, 1, 1, 'i',
                                                                                2));

                    else
            -- The best we can do is default the object owner to the same owner 
            -- as the child object. This is the majority usecase. In the future,
            -- we could add an option to Loki that would require the base object
            -- owner be included in the SQL or an error is raised.
                        l_base_object_rec.owner := ora_dict_obj_owner;
                    end if;

                    l_base_object_rec.object_name := normalize_name(regexp_substr(i_ddl, l_index_full_re, 1, 1, 'i',
                                                                                  3));

                elsif ora_sysevent in ( 'ALTER', 'DROP' ) then
          -- For ALTER and DROP, use dba_indexes over regexp functions.
                    if ora_sysevent = 'ALTER' then
            -- This property will have the object name or the TO name if it's
            -- a rename.
                        l_object_name := l_lock_details.object_name;
                    else
                        l_object_name := ora_dict_obj_name;
                    end if;

                    select
                        table_owner,
                        table_type,
                        table_name
                    into
                        l_base_object_rec.owner,
                        l_base_object_rec.object_type,
                        l_base_object_rec.object_name
                    from
                        all_indexes
                    where
                            owner = ora_dict_obj_owner
                        and index_name = l_object_name;

                end if;

                l_lock_details.owner := l_base_object_rec.owner;
                l_lock_details.object_type := l_base_object_rec.object_type;
                l_lock_details.object_name := l_base_object_rec.object_name;
            elsif l_lock_details.object_type = 'TRIGGER' then
                if ora_sysevent = 'CREATE' then
          -- Regular DML triggers and INSTEAD OF triggers on VIEWS are
          -- escalated to the base object. SYSTEM triggers are not.
                    if regexp_instr(i_ddl, l_trigger_system_re, 1, 1, 0,
                                    'in') > 0 then
                        l_base_object_rec.owner := ora_dict_obj_owner;
                        l_base_object_rec.object_type := ora_dict_obj_type;
                        l_base_object_rec.object_name := ora_dict_obj_name;
                    else
                        if regexp_instr(i_ddl, l_trigger_iot_re, 1, 1, 0,
                                        'in') > 0 then
                            l_base_object_rec.object_type := 'VIEW';
                        else
                            l_base_object_rec.object_type := 'TABLE';
                        end if;

                        l_base_object_rec.object_name := normalize_name(regexp_substr(i_ddl, l_trigger_full_re, 1, 1, 'in',
                                                                                      3));

                        if regexp_instr(i_ddl, l_trigger_base_owner_re, 1, 1, 0,
                                        'in') > 0 then
                            l_base_object_rec.owner := normalize_name(regexp_substr(i_ddl, l_trigger_full_re, 1, 1, 'in',
                                                                                    2));
                        else
              -- The best we can do is default the object owner to the same owner 
              -- as the child object. This is the majority usecase. In the future,
              -- we could add an option to Loki that would require the base object
              -- owner be included in the SQL or an error is raised.
                            l_base_object_rec.owner := ora_dict_obj_owner;
                        end if;

                    end if;
                elsif ora_sysevent in ( 'ALTER', 'DROP' ) then
          -- For ALTER and DROP, use dba_triggers over regexp functions.
                    if ora_sysevent = 'ALTER' then
            -- This property will have the object name or the TO name if it's
            -- a rename.
                        l_object_name := l_lock_details.object_name;
                    else
                        l_object_name := ora_dict_obj_name;
                    end if;
          --
                    select
                        table_owner,
                        base_object_type,
                        table_name
                    into
                        l_base_object_rec.owner,
                        l_base_object_rec.object_type,
                        l_base_object_rec.object_name
                    from
                        all_triggers
                    where
                            owner = ora_dict_obj_owner
                        and trigger_name = l_object_name;

                end if;

                l_lock_details.owner := l_base_object_rec.owner;
                l_lock_details.object_type := l_base_object_rec.object_type;
                l_lock_details.object_name := l_base_object_rec.object_name;
            end if;
        end escalate_lock;

    begin
        l_lock_details.owner := ora_dict_obj_owner;
    --
        if ora_sysevent_is_rename() then
            l_lock_details.event_is_rename := true;
            l_lock_details.object_name := get_new_name();
        else
            l_lock_details.event_is_rename := false;
            l_lock_details.object_name :=
                case
          -- See if it's a column comment and if so, extract just the object name
                    when ora_sysevent = 'COMMENT'
                         and instr(ora_dict_obj_name, '.') > 0 then
                        substr(ora_dict_obj_name,
                               1,
                               instr(ora_dict_obj_name, '.') - 1)
                    else
                        ora_dict_obj_name
                end;

        end if;

        l_lock_details.object_type := get_loki_object_type(
            i_from        => 'ORA_DICT_OBJ_TYPE',
            i_object_type => ora_dict_obj_type
        );
        escalate_lock();
        return l_lock_details;
    end get_lock_details;

    function get_lock (
        i_lock_id loki_locks.lock_id%type
    ) return loki_locks%rowtype is
        l_lock loki_locks%rowtype;
    begin
        select
            *
        into l_lock
        from
            loki_locks
        where
            lock_id = i_lock_id;

        return l_lock;
    end get_lock;

    function object_locked_by (
        i_schema_name loki_locks.schema_name%type,
        i_object_name loki_locks.object_name%type,
        i_object_type loki_locks.object_type%type
    ) return loki_users.user_id%type is
        l_user_id loki_locks.user_id%type;
    begin
        select
            user_id
        into l_user_id
        from
            loki_locks
        where
                schema_name = i_schema_name
            and object_name = i_object_name
            and object_type = i_object_type;

        return l_user_id;
    exception
        when no_data_found then
            return null;
    end object_locked_by;

    procedure create_lock (
        io_lock in out nocopy loki_locks%rowtype
    ) is
    begin
        loki_util.assert(
            i_condition => io_lock.schema_name is not null,
            i_message   => 'Loki: Schema name is not provided'
        );

        loki_util.assert(
            i_condition => io_lock.object_name is not null,
            i_message   => 'Loki: Object name is not provided'
        );

        loki_util.assert(
            i_condition => io_lock.object_type is not null,
            i_message   => 'Loki: Object type is not provided'
        );

        io_lock.user_id := coalesce(io_lock.user_id,
                                    loki_util.get_current_user().user_id);

        insert into loki_locks (
            schema_name,
            object_type,
            object_name,
            user_id,
            ddl_log_id
        ) values
            ( io_lock.schema_name,
              io_lock.object_type,
              io_lock.object_name,
              io_lock.user_id,
              io_lock.ddl_log_id )
        returning lock_id,
                  created into io_lock.lock_id, io_lock.created;

        insert into loki_locks_logs (
            lock_id,
            schema_name,
            object_type,
            object_name,
            user_id,
            locked,
            locked_by,
            ddl_log_id
        ) values
            ( io_lock.lock_id,
              io_lock.schema_name,
              io_lock.object_type,
              io_lock.object_name,
              io_lock.user_id,
              io_lock.created,
              loki_util.get_session_user(),
              io_lock.ddl_log_id );

    end create_lock;

    procedure unlock_lock (
        i_lock_id loki_locks.lock_id%type,
        i_user_id loki_locks.user_id%type
    ) is
        l_current_user loki_users%rowtype;
    begin
        loki_util.assert(
            i_condition => i_lock_id is not null,
            i_message   => 'Loki: Lock ID is invalid'
        );
        loki_util.assert(
            i_condition => i_user_id is not null,
            i_message   => 'Loki: User ID is invalid'
        );
        l_current_user := loki_util.get_current_user();
        if
            not loki_util.is_admin()
            and l_current_user.user_id != i_user_id
        then
            raise_application_error(-20000, 'Loki: Only admins can unlock other users locks');
        end if;

        delete from loki_locks
        where
            lock_id = i_lock_id;

        update loki_locks_logs
        set
            released = localtimestamp,
            released_by = loki_util.get_session_user()
        where
            lock_id = i_lock_id;

    end unlock_lock;

    procedure unlock_locks (
        i_locks t_lock_user_type
    ) is
    begin
        loki_util.assert(
            i_condition => i_locks is not null
                           or i_locks.count = 0,
            i_message   => 'Loki: Lock IDs are invalid'
        );

        for i in 1..i_locks.count loop
            unlock_lock(
                i_lock_id => i_locks(i).lock_id,
                i_user_id => i_locks(i).user_id
            );
        end loop;

    end unlock_locks;

    procedure transfer_lock (
        i_lock_id loki_locks.lock_id%type,
        i_user_id loki_users.user_id%type
    ) is
        l_lock         loki_locks%rowtype;
        l_current_user loki_users%rowtype;
    begin
        loki_util.assert(
            i_condition => i_lock_id is not null,
            i_message   => 'Loki: Lock ID is invalid'
        );
        loki_util.assert(
            i_condition => i_user_id is not null,
            i_message   => 'Loki: User ID is invalid'
        );
        l_lock := get_lock(i_lock_id);
        l_current_user := loki_util.get_current_user();
        if
            not loki_util.is_admin()
            and l_current_user.user_id != l_lock.user_id
        then
            raise_application_error(-20000, 'Loki: Only admins can transfer other users locks');
        end if;

        unlock_lock(
            i_lock_id => i_lock_id,
            i_user_id => l_lock.user_id
        );
        l_lock.user_id := i_user_id;
        create_lock(l_lock);
    end transfer_lock;

    procedure transfer_locks (
        i_lock_ids   apex_t_number,
        i_to_user_id loki_users.user_id%type
    ) is
    begin
        loki_util.assert(
            i_condition => i_lock_ids is not null
                           or i_lock_ids.count = 0,
            i_message   => 'Loki: Lock IDs are invalid'
        );

        loki_util.assert(
            i_condition => i_to_user_id is not null,
            i_message   => 'Loki: To user ID is invalid'
        );
        for i in 1..i_lock_ids.count() loop
            transfer_lock(
                i_lock_id => i_lock_ids(i),
                i_user_id => i_to_user_id
            );
        end loop;

    end transfer_locks;

    procedure handle_ddl_event is

        l_user          loki_users%rowtype;
        l_apex_user     varchar2(255);
        l_db_proxy_user varchar2(128);
        l_ddl           clob;
        l_sql_parts     ora_name_list_t;
        l_sql_count     pls_integer;
        l_sql_chunk     varchar2(32767);
        l_ddl_preview   loki_ddl_logs.ddl_preview%type;
        l_ddl_log_id    loki_ddl_logs.ddl_log_id%type;
        l_lock_details  r_lock_details_type;
        l_lock_user_id  loki_users.user_id%type;
        l_lock_user     loki_users%rowtype;
        l_lock          loki_locks%rowtype;
    begin
    -- Check if user is registered.
        l_user := loki_util.get_current_user();
        if l_user.user_id is null then
            l_apex_user := upper(sys_context('APEX$SESSION', 'APP_USER'));
            l_db_proxy_user := sys_context('USERENV', 'PROXY_USER');
            raise_application_error(-20000, 'Loki: user is not registered (APEX User: '
                                            || l_apex_user
                                            || '; DB User: '
                                            || user
                                            || '; DB Proxy User: '
                                            || l_db_proxy_user
                                            || ')');

        end if;

        dbms_lob.createtemporary(l_ddl, true);

    -- Reconstruct the SQL statement and assign to l_ddl. The DDL statment
    -- is important for RENAMEs.
        l_sql_count := ora_sql_txt(sql_text => l_sql_parts);

    -- The following check was added because there are ways to suppress the
    -- SQL statement, such as when resetting a password, and if that's done
    -- then there's really not much Loki can do for now. HCTOOLS-165
        if l_sql_count is null then
            return;
        end if;
        for chunk_number in 1..l_sql_count loop
            l_sql_chunk := l_sql_parts(chunk_number);
            if chunk_number = l_sql_count then
                l_sql_chunk := rtrim(
                    l_sql_parts(chunk_number),
                    chr(0)
                );
            end if;

            if length(l_sql_chunk) > 0 then
                dbms_lob.writeappend(l_ddl,
                                     length(l_sql_chunk),
                                     l_sql_chunk);
            end if;

        end loop;

    -- Log the DDL statement early as the ora_sysevent is not checked
    -- for DDL logging, so events like GRANT, REVOKE, AUDIT, etc. will
    -- be logged. This will be rolledback later if an exception is
    -- raised, otherwise it w(ill be committed with the DDL.
        if dbms_lob.getlength(l_ddl) <= 128 then
            l_ddl_preview := l_ddl;
        else
            l_ddl_preview := dbms_lob.substr(l_ddl, 128, 1);
        end if;

        insert into loki_ddl_logs (
            ddl,
            ddl_preview,
            schema_name,
            object_name,
            object_type,
            event
        ) values
            ( l_ddl,
              l_ddl_preview,
              ora_dict_obj_owner,
              ora_dict_obj_name,
              ora_dict_obj_type,
              ora_sysevent )
        returning ddl_log_id into l_ddl_log_id;

    -- ABOVE THIS POINT IS DDL LOGGING/HISTORY LOGIC. BELOW THIS POINT IS
    -- LOCKING LOGIC.

    -- Only the following sysevents participate in Loki's locking logic
    -- See https://gbujira.us.oracle.com/browse/HCTOOLS-151 for future change.
        if ora_sysevent not in ( 'CREATE', 'ALTER', 'DROP', 'COMMENT', 'RENAME' ) then
            return;
        end if;

    -- Only the types that Loki has been tested for should participate
    -- in locking.
        if not locking_supported(ora_dict_obj_type) then
            return;
        end if;
        l_lock_details := get_lock_details(l_ddl);

    -- Check whether the ddl executed was as a result of a drop table, leading to objects in the recycle bin.
    -- If this is the case then exit.
        if
            ora_dict_obj_name like 'BIN$%'
            and l_lock_details.event_is_rename
        then
            return;
        end if;
        l_lock_user_id := object_locked_by(
            i_schema_name => l_lock_details.owner,
            i_object_name => l_lock_details.object_name,
            i_object_type => l_lock_details.object_type
        );

        if l_user.user_id = l_lock_user_id then
            if l_lock_details.event_is_rename then
                update loki_locks
                set
                    object_name = l_lock_details.object_name,
                    ddl_log_id = l_ddl_log_id
                where
                        object_name = ora_dict_obj_name
                    and schema_name = ora_dict_obj_owner;

            end if;

            return;
        elsif l_user.user_id != l_lock_user_id then
            l_lock_user := loki_util.get_user(i_user_id => l_lock_user_id);
            raise_application_error(-20001, 'Loki: '
                                            || l_lock_details.object_name
                                            || ' is locked by '
                                            || l_lock_user.full_name);

        elsif l_lock_user_id is null then
            l_lock.schema_name := l_lock_details.owner;
            l_lock.object_type := l_lock_details.object_type;
            l_lock.object_name := l_lock_details.object_name;
            l_lock.user_id := l_user.user_id;
            l_lock.ddl_log_id := l_ddl_log_id;
            create_lock(l_lock);
        end if;

    end handle_ddl_event;

    procedure clear_locks_log (
        i_log_retention_months pls_integer
    ) is
    begin
        delete from loki_locks_logs
        where
            released <= current_timestamp - interval '1' month;

    end clear_locks_log;

    procedure clear_ddl_log (
        i_log_retention_months pls_integer
    ) is
    begin
        delete from loki_ddl_logs
        where
            logged <= current_timestamp - interval '1' month;

    end clear_ddl_log;

end loki_lock;
/


-- sqlcl_snapshot {"hash":"b951853c02a5a2cc2f56d7d3fce521c8e7f92400","type":"PACKAGE_BODY","name":"LOKI_LOCK","schemaName":"LOKI","sxml":""}