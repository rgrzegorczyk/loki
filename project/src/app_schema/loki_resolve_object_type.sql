-- Install this function once in every application schema protected by LOKI.
-- AUTHID DEFINER makes USER_OBJECTS describe that application schema when the
-- central LOKI package invokes the function. This avoids granting LOKI access to
-- DBA_OBJECTS or to individual application objects.
create or replace function loki_resolve_object_type (
    i_object_name in varchar2
) return varchar2
    authid definer
is
    l_object_type varchar2(128);
begin
    -- A materialized view can also have a TABLE entry for its storage object.
    -- Prefer the logical MATERIALIZED VIEW entry, then VIEW, then TABLE.
    select
        max(object_type) keep (
            dense_rank first
            order by
                case object_type
                    when 'MATERIALIZED VIEW' then
                        1
                    when 'VIEW' then
                        2
                    when 'TABLE' then
                        3
                end
        )
    into l_object_type
    from
        user_objects
    where
            object_name = i_object_name
        and object_type in ( 'TABLE', 'VIEW', 'MATERIALIZED VIEW' );

    return l_object_type;
end loki_resolve_object_type;
/

-- The central definer-rights package needs this direct object privilege; a role
-- grant is not sufficient for stored PL/SQL privilege checking.
grant execute on loki_resolve_object_type to loki;
