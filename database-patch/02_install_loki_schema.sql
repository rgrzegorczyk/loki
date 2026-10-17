set serveroutput on
set verify off
whenever sqlerror exit sql.sqlcode rollback

prompt Rechecking the central Loki schema...
@@00_precheck_loki.sql
whenever sqlerror exit sql.sqlcode rollback

prompt Installing LOKI_UTIL package specification...
@@../project/src/database/loki/package_specs/loki_util.sql

prompt Installing LOKI_UTIL package body...
@@../project/src/database/loki/package_bodies/loki_util.sql

prompt Installing LOKI_LOCK package specification...
@@../project/src/database/loki/package_specs/loki_lock.sql

prompt Installing LOKI_LOCK package body...
@@../project/src/database/loki/package_bodies/loki_lock.sql

prompt Checking the compiled package objects before changing settings or jobs...
@@sql/02_validate_packages.sql

prompt Persisting the default lock-retention setting when needed...
@@sql/03_persist_settings.sql

prompt Creating or verifying the abandoned-lock cleanup job...
@@sql/04_create_cleanup_job.sql

prompt Verifying the database patch...
@@sql/05_postcheck.sql

prompt Loki database patch installation completed successfully.
whenever sqlerror continue none
