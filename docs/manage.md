# Management and Maintenance

## Backend

Some common management tasks are described below.

### Update image
Deployment images can be changed simply by changing the image tag in the deployment configuration.

Images are built from each PR to `main`, as well as pushes to `main`. To deploy a specific PR, simply change the image tag to the PR number.

```yml title="Change backend image to PR#123"
      image: ghcr.io/wgbh-mla/ov-wag:pr-123
```

To use the latest production image, change the image tag to `main`.

```yml title="Change backend image to main"
      image: ghcr.io/wgbh-mla/ov-wag:main
```

!!! kube "Change image using `kubectl`"
    This can also be done directly with `kubectl`:


    ```bash title="set backend version to PR#123"
    kubectl set image deployment.apps/ov-wag ov-wag=ghcr.io/wgbh-mla/ov-wag:pr-123
    ```

### Scale deployment
To scale a deployment, simply change the `replicas` value in the deployment configuration.

```yml title="Scale backend to 3 replicas"
  replicas: 3
```

### Update configuration
To update the configuration of a deployment, simply change the value in the deployment configuration.

```yml title="Change backend configuration"
        - name: OV_DB_PASSWORD
          value: NEW POSTGRES PASSWORD HERE
```

## Database
Data is stored in a PostGreSQL database, hosted in AWS RDS. This page describes common maintenance tasks for the database.

For more details about creating and configuring the database, see [setup#db](setup.md#db).

### Backup
Backups are created automatically by AWS RDS. To create a manual backup, use the AWS console.

### Restore
Restore the database by creating a new RDS instance from a backup instance in the AWS console. 

Then, update the `OV_DB_HOST` environment variable in the backend deployment to point to the new database instance.

## # Migrate
If the Wagtail models have changed, the database must be migrated to reflect the changes. This can be done by running the following command:

```bash
ov migrate
```
