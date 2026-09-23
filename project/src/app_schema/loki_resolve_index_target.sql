-- Install this procedure once in every application schema protected by LOKI.
-- AUTHID DEFINER makes USER_INDEXES describe that application schema when the
-- central LOKI package invokes the procedure. This avoids granting LOKI access
-- to DBA_INDEXES or to individual application objects.
create or replace procedure loki_resolve_index_target (
    i_index_name  in  varchar2,
    o_table_owner out varchar2,
    o_table_type  out varchar2,
    o_table_name  out varchar2
)
    authid definer
is
begin
    select
        table_owner,
        table_type,
        table_name
    into
        o_table_owner,
        o_table_type,
        o_table_name
    from
        user_indexes
    where
        index_name = i_index_name;
end loki_resolve_index_target;
/

-- The central definer-rights package needs this direct object privilege; a role
-- grant is not sufficient for stored PL/SQL privilege checking.
grant execute on loki_resolve_index_target to loki;
