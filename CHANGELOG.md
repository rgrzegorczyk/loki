# Changelog

All notable changes to Loki are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Changes that have not yet been released are collected under **Unreleased**. When
a release is published, its entries are moved to a section containing the
release version and date.

## [Unreleased]

### Added

- A two-path quick-start guide for upgrading an existing Loki 24.1.1
  installation or setting up Loki for the first time.

## [25.0] - 2026-10-17

### Added

#### Database-only upgrade package for Loki 24.1.1

Added an ordered SQLcl/SQL*Plus installation path for the fixes from issues #5
and #6. It includes a central-schema precheck, per-protected-schema resolver
installation, central package and job installation, post-install verification,
and rollback guidance. The upgrade does not import or modify the Oracle APEX
application.

### Fixed

#### Correct lock handling for comments, indexes, and triggers ([#6](https://github.com/rgrzegorczyk/loki/issues/6))

**Problem:** Loki can fail before it creates or enforces a lock for `COMMENT ON
TABLE`, `COMMENT ON COLUMN`, `DROP INDEX`, and `ALTER` or `DROP TRIGGER` in a
protected application schema. The central `LOKI_LOCK` package runs with
definer's rights, so its `ALL_OBJECTS`, `ALL_INDEXES`, and `ALL_TRIGGERS`
lookups use the LOKI schema's visibility instead of the protected schema's
visibility. This can raise `NO_DATA_FOUND` and abort the DDL operation.

**Fix:** Each protected application schema provides one definer-rights
`LOKI_RESOLVER` package. It resolves objects, index targets, and trigger targets
through the schema's local `USER_OBJECTS`, `USER_INDEXES`, and `USER_TRIGGERS`
views. The LOKI schema receives only direct `EXECUTE` access to this package.

- `COMMENT ON TABLE` and `COMMENT ON COLUMN` resolve to the protected
  table, view, or materialized view.
- `DROP INDEX` resolves to the index's base table.
- `ALTER TRIGGER` and `DROP TRIGGER` resolve DML and INSTEAD OF triggers
  to their base table or view; schema and database event triggers resolve
  to the trigger itself.
- The change does not grant access to `DBA_*` views or individual application
  objects.
- `ALTER INDEX` and index or trigger rename handling are outside this change.
- No table structure or Oracle APEX application changes are required.

#### Automatic cleanup of abandoned locks ([#5](https://github.com/rgrzegorczyk/loki/issues/5))

**Problem:** In Loki 24.1.1, locks remained active until a developer or
administrator released them manually. Forgotten locks could therefore block
other developers indefinitely.

**Fix:** Loki now tracks the most recent supported DDL operation performed by
the lock owner on the protected object and automatically removes inactive locks
using the hourly `LOKI_LOCKS_CLEAR` Scheduler job.

- The default retention period is 2 hours and can be configured using
  `locks_retention_hours` in `LOKI_SETTINGS.JSON_CONTENT`.
- Each supported DDL operation performed by the lock owner on the same object
  refreshes the lock activity time.
- An expired lock is removed during the first hourly job run after the
  retention period. With the default setting, this normally occurs 2–3 hours
  after the last supported DDL operation.
- Manually created locks without a linked DDL log use their creation time.
- Automatically removed locks are marked as released in `LOKI_LOCKS_LOGS`.
- The change requires no table structure or Oracle APEX application changes.

