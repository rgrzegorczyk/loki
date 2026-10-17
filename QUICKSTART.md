# Loki 25.0 quick start

Loki 25.0 is a database-only release. The Oracle APEX application remains
unchanged at version 24.1.1, while its database components are upgraded to
Loki 25.0.

Choose the path that matches your environment.

## 1. I already have Loki 24.1.1

You do not need to reinstall or replace the Oracle APEX application.

### What you get

- Automatic cleanup of abandoned locks.
- A configurable inactivity period, with a default of 2 hours.
- An hourly cleanup job named `LOKI_LOCKS_CLEAR`.
- Correct lock handling for comments, dropped indexes, and altered or dropped
  triggers.
- No changes to existing Loki tables or to the Oracle APEX application.

### Install the patch

1. Download and extract the source archive from the
   [Loki 25.0 release](https://github.com/rgrzegorczyk/loki/releases/tag/25.0).
2. Back up the `LOKI` schema.
3. Open SQLcl or SQL*Plus in the extracted repository directory.
4. Connect as `LOKI` and run:

   ```sql
   @database-patch/00_precheck_loki.sql
   ```

5. Connect as the owner of an application schema protected by Loki and run:

   ```sql
   @database-patch/01_install_protected_schema.sql
   ```

   Repeat this step for every protected application schema.

6. Reconnect as `LOKI` and run:

   ```sql
   @database-patch/02_install_loki_schema.sql
   ```

The installation is successful when the script finishes with:

```text
Loki database patch installation completed successfully.
```

The `LOKI` schema must have the `CREATE JOB` privilege. If `LOKI` has no
password, connect through an authorized proxy account. The precheck requires
the session user to be `LOKI`.

See the [complete database patch instructions](database-patch/README.md) for
all requirements and rollback information.

## 2. I do not have Loki yet

Install the Loki 24.1.1 Oracle APEX application first, and then apply the Loki
25.0 database patch.

1. Download and extract the source archive from the
   [Loki 25.0 release](https://github.com/rgrzegorczyk/loki/releases/tag/25.0).
2. Create the `LOKI` database schema and add it to your Oracle APEX workspace.
3. Import `loki.sql` through Oracle APEX App Builder.
4. Install the application's supporting objects.
5. Run the application and complete its initial configuration:
   - add Loki users;
   - add every application schema that Loki should protect;
   - install the generated Loki DDL triggers and required grants.
6. Apply the database patch by following all steps in
   [I already have Loki 24.1.1](#1-i-already-have-loki-2411).

For a detailed walkthrough of the initial Oracle APEX installation, see
[Loki - Installation and configuration](https://rafal.hashnode.dev/loki-installation-and-configuration-no-more-code-conflicts-in-the-shared-oracle-dev-database).

After both parts are complete, the environment consists of the unchanged Loki
24.1.1 Oracle APEX application and the Loki 25.0 database components.
