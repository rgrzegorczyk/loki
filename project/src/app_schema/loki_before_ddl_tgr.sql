create or replace trigger pss.loki_before_ddl_tgr before ddl on PSS.schema
begin
  execute immediate 'begin LOKI.loki_lock.handle_ddl_event(); end;';
end loki_before_ddl_tgr;