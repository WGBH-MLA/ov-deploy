# Database Maintenance
Data is stored in a PostGreSQL database, hosted in AWS RDS. This page describes common maintenance tasks for the database.

For more details about creating and configuring the database, see [setup#db](setup.md#db).

## Backup
Backups are created automatically by AWS RDS. To create a manual backup, use the AWS console.

## Restore
Restore the database by creating a new RDS instance from a backup instance in the AWS console. 

Then, update the `OV_DB_HOST` environment variable in the backend deployment to point to the new database instance.

## Migrate
If the Wagtail models have changed, the database must be migrated to reflect the changes. This can be done by running the following command:

```bash
ov migrate
```
