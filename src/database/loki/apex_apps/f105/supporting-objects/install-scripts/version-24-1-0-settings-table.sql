create table loki_settings (
  json_content clob not null
);
alter table loki_settings add check ( json_content is json );

declare
  l_settings_json clob;
begin
  l_settings_json := '{
    "locks_log_retention_months": 3,
    "ddl_log_retention_months": 3
  }';

  insert into loki_settings (json_content)
  values (l_settings_json);
end;
/