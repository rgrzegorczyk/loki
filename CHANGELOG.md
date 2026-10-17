# Changelog

All notable changes to Loki are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Changes that have not yet been released are collected under **Unreleased**. When
a release is published, its entries are moved to a section containing the
release version and date.

## [Unreleased]

### Fixed

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

