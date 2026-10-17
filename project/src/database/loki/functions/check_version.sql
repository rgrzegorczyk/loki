create or replace function loki.check_version (
    i_version in varchar2
) return boolean is
    c_curr_version        constant varchar2(6) := '24.1.1';
    l_cur_version_numbers apex_t_number;
    l_inc_version_numbers apex_t_number;
begin
    loki_util.assert(
        i_condition => regexp_like(i_version, '^\d+\.\d+\.\d+$'),
        i_message   => 'LOKI: Invalid version format'
    );

    l_cur_version_numbers := apex_string.split_numbers(c_curr_version, '.');
    l_inc_version_numbers := apex_string.split_numbers(i_version, '.');
    if l_cur_version_numbers(1) < l_inc_version_numbers(1) then
        return true;
    end if;
    if
        l_cur_version_numbers(1) = l_inc_version_numbers(1)
        and l_cur_version_numbers(2) < l_inc_version_numbers(2)
    then
        return true;
    end if;

    if
        l_cur_version_numbers(1) = l_inc_version_numbers(1)
        and l_cur_version_numbers(2) = l_inc_version_numbers(2)
        and l_cur_version_numbers(3) < l_inc_version_numbers(3)
    then
        return true;
    end if;

    return false;
end check_version;
/


-- sqlcl_snapshot {"hash":"133aa5bf932ec179f07d0dfccb0081bc9b78e0bc","type":"FUNCTION","name":"CHECK_VERSION","schemaName":"LOKI","sxml":""}