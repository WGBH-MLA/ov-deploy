# Database

Data is stored in a PostGreSQL database, with a single worker node running in kubernetes. This page describes the backup and restore process of data management.

See [setup/#db](setup.md#db) for more details about creating and configuring the database.

## `./db`

Some basic database maintenance commands can be performed with the `./db` tool.

### Options

#### Context

: **Required** - The kubernetes namespace to execute the command.

Must be one of:

- `openvault`
- `openvault-demo`

!!! kube "Setting up kubectl context"

    The following commands assume a properly configured kubectl context. See [production setup](setup.md#production) for details.

### Commands

#### backup

Backup the database and save to a local file named `db_{TIMESTAMP}.sql`

#### restore

Restore the database from a file.

Example:

```bash title="Restore the demo instance from a local backup copy"
./db -c openvault-demo restore db_2022-10-26T11.11.11.sql
```
