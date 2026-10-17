declare
    l_settings loki_util.r_settings_type;
begin
    l_settings := loki_util.get_settings();

    if l_settings.locks_retention_hours is null then
        l_settings.locks_retention_hours := 2;
    end if;

    loki_util.set_settings(l_settings);
    commit;

    dbms_output.put_line(
        'LOKI_SETTINGS.locks_retention_hours = '
        || l_settings.locks_retention_hours
    );
end;
/
