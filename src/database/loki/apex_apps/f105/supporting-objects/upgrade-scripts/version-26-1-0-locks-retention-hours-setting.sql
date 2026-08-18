begin
    update /*+ no_parallel */ loki_settings
    set
        json_content = json_mergepatch(
            json_content,
            '{"locks_retention_hours":12}'
        )
    where
        not json_exists(json_content, '$.locks_retention_hours');
end;
/
