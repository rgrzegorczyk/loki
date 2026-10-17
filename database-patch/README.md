# Loki 25.0 database patch

This patch upgrades the database components of an existing Loki 24.1.1
installation to Loki 25.0. It installs the fixes from
[#5](https://github.com/rgrzegorczyk/loki/issues/5) and
[#6](https://github.com/rgrzegorczyk/loki/issues/6).

It does not modify the Oracle APEX application or any table structure. The
APEX application therefore continues to display version 24.1.1.

## Included changes

- Automatic removal of abandoned locks. The default inactivity period is
  2 hours and the cleanup job runs hourly.
- Refreshing lock activity after another supported DDL operation by its owner.
- Correct lock resolution for comments, dropped indexes, and altered or
  dropped triggers.
- A `LOKI_RESOLVER` package in every protected application schema.

See [`CHANGELOG.md`](../CHANGELOG.md) for detailed descriptions.

## Requirements

- Loki 24.1.1 is already installed in schema `LOKI`.
- Run the scripts using SQLcl or SQL*Plus from the repository root.
- You need access to `LOKI` and to every application schema protected by Loki.
- The `LOKI` session needs `CREATE JOB` to create the cleanup job.
- Back up the `LOKI` schema before installing the patch.

The only new cross-schema grant is:

```sql
grant execute on loki_resolver to loki;
```

No access to `DBA_*` views or application objects is required.

If `LOKI` has no password, connect through an authorized proxy account. The
precheck requires `SESSION_USER` to be `LOKI`.

## Installation

### 1. Check the central schema

Connect as `LOKI` and run:

```sql
@database-patch/00_precheck_loki.sql
```

Continue only if the precheck succeeds.

### 2. Install the resolver in every protected schema

Connect as the owner of a protected application schema and run:

```sql
@database-patch/01_install_protected_schema.sql
```

Repeat this step for every schema protected by Loki. The script creates or
replaces `LOKI_RESOLVER` and grants `EXECUTE` on it to `LOKI`. Existing Loki
DDL triggers are not changed.

### 3. Upgrade the central schema

Reconnect as `LOKI` and run:

```sql
@database-patch/02_install_loki_schema.sql
```

The script:

1. replaces the `LOKI_UTIL` and `LOKI_LOCK` packages;
2. adds the default `locks_retention_hours` setting when missing;
3. creates and enables the hourly `LOKI_LOCKS_CLEAR` job when missing;
4. verifies the packages, setting, and Scheduler job.

The installation is successful when the script finishes with:

```text
Loki database patch installation completed successfully.
```

## Rollback

Restore the original Loki 24.1.1 definitions of `LOKI_UTIL` and `LOKI_LOCK`
from your backup. The additional JSON setting can remain because the old code
ignores it. Removing the Scheduler job or resolver packages is not required to
restore the old package behaviour.
