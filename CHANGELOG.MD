# Changelog

This file documents user-visible changes, the problems that motivated them,
and reproducible test cases for regressions.

## Unreleased

### ALTER or DROP TRIGGER fails in a protected application schema

#### Status

Fixed in the source tree. Database installation and verification are pending.

#### Problem

For an existing trigger, LOKI resolves its protected base object through
`ALL_TRIGGERS` from the definer-rights `LOKI.LOKI_LOCK` package. A trigger
owned by a protected application schema may not be visible to LOKI, causing an
unhandled `NO_DATA_FOUND` before lock enforcement.

#### Resolution

The application schema's definer-rights `LOKI_RESOLVER` package now provides
`GET_TRIGGER_TARGET`, which reads local `USER_TRIGGERS`. DML and INSTEAD OF
triggers resolve to their table or view. Schema and database event triggers
resolve to the trigger itself, consistently with the existing `CREATE
TRIGGER` behavior. LOKI invokes this resolver for `ALTER TRIGGER` and `DROP
TRIGGER` without requiring dictionary or application-object grants.

Trigger rename handling is not changed by this fix.

#### Regression test

In a protected application schema, create a table and a DML trigger, then
alter and drop the trigger:

```sql
create table loki_trigger_fix_test (
    id number
);

create or replace trigger loki_trigger_fix_test_bir
    before insert on loki_trigger_fix_test
begin
    null;
end;
/

alter trigger loki_trigger_fix_test_bir disable;
drop trigger loki_trigger_fix_test_bir;
drop table loki_trigger_fix_test purge;
```

`ALTER TRIGGER` and `DROP TRIGGER` must complete without an unhandled
`ORA-01403`/`ORA-04088` error. Normal LOKI lock enforcement still applies.

### DROP INDEX fails for indexes in a protected application schema

#### Status

Fixed in the source tree. Database installation and verification are pending.

#### Problem

`DROP INDEX` resolves the index's base object through `ALL_INDEXES` from the
definer-rights `LOKI.LOKI_LOCK` package. An index owned by a protected
application schema may not be visible to LOKI, causing an unhandled
`NO_DATA_FOUND` before lock enforcement.

#### Resolution

Each protected application schema provides a definer-rights package named
`LOKI_RESOLVER`. Its `GET_INDEX_TARGET` procedure reads the local
`USER_INDEXES` view and returns the base table owner, type, and name. LOKI has
only direct `EXECUTE` access to the package and invokes the procedure for
`DROP INDEX`.

`ALTER INDEX`, index rename handling, and trigger target resolution are not
changed by this fix.

### COMMENT DDL fails for objects in a protected application schema

#### Status

Fixed in the source tree. Database installation and verification are pending.

#### Problem

Running `COMMENT ON TABLE` or `COMMENT ON COLUMN` in an application schema
protected by a LOKI schema DDL trigger can fail even when the object is not
locked.

Additionally, `COMMENT ON COLUMN` can be logged without creating a lock because
Oracle reports its raw dictionary type as `COLUMN`, which was rejected by the
generic supported-type filter before base-object resolution ran.

The failure happens while LOKI is resolving the base object's type. Oracle's
DDL trigger attributes do not provide enough information for this operation:
`ORA_DICT_OBJ_TYPE` may identify the event as `TABLE` or `COLUMN`, while LOKI
must associate the event with a `TABLE`, `VIEW`, or `MATERIALIZED_VIEW` lock.

The original implementation performs this lookup through `ALL_OBJECTS` from
the `LOKI.LOKI_LOCK` package. The package uses definer's rights, so
`ALL_OBJECTS` is evaluated with LOKI's object visibility rather than the
application schema owner's visibility. If LOKI has no privilege on the target
object, the query returns no rows and raises `NO_DATA_FOUND` before LOKI checks
whether the object is locked.

#### Preconditions

- `LOKI.LOKI_LOCK` contains the original `ALL_OBJECTS` lookup in its
  `COMMENT` handling path.
- The application schema has an enabled `LOKI_BEFORE_DDL_TGR` schema trigger.
- LOKI has no direct privilege on the test table and no system privilege that
  makes the table visible through `ALL_OBJECTS`.

#### Reproduction

Connect as the owner of a schema protected by LOKI and create a new table:

```sql
create table loki_comment_repro (
    id number
);
```

`CREATE TABLE` should succeed because that DDL path can use
`ORA_DICT_OBJ_TYPE` directly and does not need the problematic lookup.

Confirm separately, while connected as `LOKI`, that the new table is not
visible:

```sql
select owner, object_name, object_type
from all_objects
where owner = '<APPLICATION_SCHEMA>'
  and object_name = 'LOKI_COMMENT_REPRO';
```

The query must return no rows. Then reconnect as the application schema owner
and execute either of the following statements:

```sql
comment on table loki_comment_repro is 'LOKI reproduction test';
```

or:

```sql
comment on column loki_comment_repro.id is 'LOKI reproduction test';
```

#### Actual result

The following output was observed when reproducing the problem in the `PSS`
schema:

```text
Error starting at line : 1 in command -
comment on table loki_comment_repro is 'LOKI reproduction test'
Error report -
ORA-04088: error during execution of trigger 'PSS.LOKI_BEFORE_DDL_TGR'
ORA-01403: no data found
ORA-01403: no data found
ORA-06512: at "LOKI.LOKI_LOCK", line 153
ORA-06512: at "LOKI.LOKI_LOCK", line 315
ORA-06512: at "LOKI.LOKI_LOCK", line 626
ORA-06512: at line 1
ORA-06512: at line 2
```

Oracle documents `ORA-04088` at
[ORA-04088 error help](https://docs.oracle.com/error-help/db/ora-04088/).
Package line numbers may change as the implementation evolves, but
`ORA-01403` raised during execution of `LOKI.LOKI_LOCK` is the relevant root
failure. The comment is not applied. The failure occurs regardless of whether
the test object has a LOKI lock because target-type resolution runs before the
lock lookup.

#### Expected result

- A comment on an unlocked object succeeds.
- A comment on an object locked by the current LOKI user succeeds and refreshes
  the lock's DDL reference as appropriate.
- A comment on an object locked by another LOKI user is rejected with LOKI's
  intentional lock error, rather than an Oracle dictionary lookup error.
- No broad data dictionary privilege should be required by a standard LOKI
  installation.

#### Resolution

Each protected application schema provides a stable definer-rights package
named `LOKI_RESOLVER`. Its `GET_OBJECT_TYPE` function resolves `TABLE`, `VIEW`,
and `MATERIALIZED VIEW` targets through that schema's `USER_OBJECTS` view.
LOKI is granted only `EXECUTE` on this resolver package and calls the function
when handling `COMMENT` DDL.

This preserves lock creation for comments on previously unlocked objects and
does not require access to `SYS.DBA_OBJECTS`, grants on individual application
objects, or a site-specific dictionary view. The resolver is installed once
per protected schema and automatically reflects later object changes.

The locking filter also allows supported `COMMENT` targets, including the raw
`COLUMN` event type, to reach the resolver before deciding which base-object
lock to create or enforce.

#### Cleanup

Connect as the application schema owner:

```sql
drop table loki_comment_repro purge;
```
