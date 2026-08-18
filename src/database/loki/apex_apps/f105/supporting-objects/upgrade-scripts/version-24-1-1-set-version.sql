create or replace function check_version (
  i_version in varchar2
) return boolean is
  c_curr_version        constant varchar2(6) := '24.1.1';
  l_cur_version_numbers apex_t_number;
  l_inc_version_numbers apex_t_number;
begin
  if not regexp_like(i_version, '^\d+\.\d+\.\d+$') then
    raise_application_error(-20000, 'LOKI: Invalid version format');
  end if;

  l_cur_version_numbers := apex_string.split_numbers(
    c_curr_version,
    '.'
  );
  l_inc_version_numbers := apex_string.split_numbers(
    i_version,
    '.'
  );
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