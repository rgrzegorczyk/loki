-- Install this package in every application schema protected by Loki.
-- AUTHID DEFINER makes USER_OBJECTS, USER_INDEXES, and USER_TRIGGERS describe
-- the protected application schema when the central LOKI package invokes the
-- resolver. This avoids grants on DBA_* views or application objects.
create or replace package loki_resolver
    authid definer
as
    function get_object_type (
        i_object_name in varchar2
    ) return varchar2;

    procedure get_index_target (
        i_index_name  in  varchar2,
        o_table_owner out varchar2,
        o_table_type  out varchar2,
        o_table_name  out varchar2
    );

    procedure get_trigger_target (
        i_trigger_name in  varchar2,
        o_object_owner out varchar2,
        o_object_type  out varchar2,
        o_object_name  out varchar2
    );
end loki_resolver;
/

create or replace package body loki_resolver as

    function get_object_type (
        i_object_name in varchar2
    ) return varchar2 is
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
    end get_object_type;

    procedure get_index_target (
        i_index_name  in  varchar2,
        o_table_owner out varchar2,
        o_table_type  out varchar2,
        o_table_name  out varchar2
    ) is
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
    end get_index_target;

    procedure get_trigger_target (
        i_trigger_name in  varchar2,
        o_object_owner out varchar2,
        o_object_type  out varchar2,
        o_object_name  out varchar2
    ) is
        l_table_owner      varchar2(128);
        l_base_object_type varchar2(128);
        l_table_name       varchar2(128);
    begin
        select
            table_owner,
            base_object_type,
            table_name
        into
            l_table_owner,
            l_base_object_type,
            l_table_name
        from
            user_triggers
        where
            trigger_name = i_trigger_name;

        -- DML and INSTEAD OF triggers protect their table or view. Schema and
        -- database event triggers have no such base object, so protect the
        -- trigger itself, matching the CREATE TRIGGER path in LOKI_LOCK.
        if
            l_base_object_type in ( 'TABLE', 'VIEW' )
            and l_table_name is not null
        then
            o_object_owner := l_table_owner;
            o_object_type := l_base_object_type;
            o_object_name := l_table_name;
        else
            o_object_owner := user;
            o_object_type := 'TRIGGER';
            o_object_name := i_trigger_name;
        end if;
    end get_trigger_target;

end loki_resolver;
/

-- This must be a direct object grant because LOKI_LOCK is a stored
-- definer-rights package. Replace LOKI if the central schema has another name.
grant execute on loki_resolver to loki;
