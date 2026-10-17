# Protected application schema objects

For an upgrade of an existing Loki 24.1.1 installation, follow the complete
[database patch instructions](../../../database-patch/README.md). This file
documents the resolver object itself and its issue #6 deployment details.

`LOKI_RESOLVER` is required in every application schema protected by the
database patch. It lets the central `LOKI.LOKI_LOCK` package resolve comment,
index, and trigger targets through the protected schema's local `USER_*` views
without broad data dictionary privileges.

## Required privilege

The resolver script grants only:

```sql
grant execute on loki_resolver to loki;
```

This must be a direct object grant because `LOKI_LOCK` is stored definer-rights
PL/SQL. If the central Loki schema is not named `LOKI`, replace the grantee in
`loki_resolver.sql` before running it.

Do not grant `SELECT ANY DICTIONARY`, access to `DBA_*` views, or access to
individual application objects for this patch.

## Upgrade order

Run the scripts from the repository root.

1. Connect as the owner of each protected application schema, using a Loki
   registered database or proxy identity, and install the resolver:

   ```sql
   @project/src/app_schema/loki_resolver.sql
   show errors package loki_resolver
   show errors package body loki_resolver
   ```

2. Confirm that the package specification and body are valid:

   ```sql
   select object_type, object_name, status
   from user_objects
   where object_name = 'LOKI_RESOLVER'
   order by object_type;
   ```

3. Repeat steps 1 and 2 for every schema protected by Loki.

4. Only after every protected schema has its resolver, connect as the central
   `LOKI` schema and install the updated package body:

   ```sql
   @project/src/database/loki/package_bodies/loki_lock.sql
   show errors package body loki_lock
   ```

5. Confirm that the central package body is valid:

   ```sql
   select object_type, object_name, status
   from user_objects
   where object_name = 'LOKI_LOCK';

   select line, position, text
   from user_errors
   where name = 'LOKI_LOCK'
   order by sequence;
   ```

The existing schema or database DDL trigger remains unchanged. New protected
schemas must install `LOKI_RESOLVER` before they start using the updated central
package.

## Manual regression test

Run this test only in a development schema protected by Loki:

```sql
create table loki_resolver_test (
    id number
);

comment on table loki_resolver_test is 'LOKI test table';
comment on column loki_resolver_test.id is 'LOKI test column';

create index loki_resolver_test_ix
    on loki_resolver_test (id);

drop index loki_resolver_test_ix;

create or replace trigger loki_resolver_test_bir
    before insert on loki_resolver_test
begin
    null;
end;
/

alter trigger loki_resolver_test_bir disable;
alter trigger loki_resolver_test_bir enable;

drop trigger loki_resolver_test_bir;
drop table loki_resolver_test;
```

All statements must complete without an unhandled `ORA-01403` or `ORA-04088`.
Normal Loki lock ownership rules still apply.

`ALTER INDEX`, index rename, and trigger rename are outside the scope of this
patch.
