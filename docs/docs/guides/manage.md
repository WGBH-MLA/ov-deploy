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

## Elasticsearch
Wagtail indexes its pages in Elasticsearch, and the frontend searches them. Wagtail should connect as its own user with a role limited to its indices, instead of the built-in `elastic` superuser.

### Create the Wagtail role and user
Run these as a user that can manage security, such as `elastic`. They can be pasted into Kibana Dev Tools, or sent with `curl`.

The role grants access to indices starting with the Wagtail index prefix, set by `ES_INDEX_PREFIX` (default `ov_`). Wagtail rebuilds each index under a new name and then switches an alias to it, so the role needs `manage` as well as `read` and `write`.

```http title="Create the role"
PUT _security/role/wagtail
{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": ["ov_*"],
      "privileges": ["manage", "read", "write"]
    }
  ]
}
```

Generate a password:

```bash
openssl rand -base64 24
```

```http title="Create the user"
PUT _security/user/wagtail
{
  "password": "GENERATED PASSWORD HERE",
  "roles": ["wagtail"],
  "full_name": "Wagtail"
}
```

!!! kube "Create them with `curl`"

    ```bash
    curl -u elastic -X PUT "$ES_URL/_security/role/wagtail" \
      -H 'Content-Type: application/json' \
      -d '{"cluster": ["monitor"], "indices": [{"names": ["ov_*"], "privileges": ["manage", "read", "write"]}]}'
    ```

    ```bash
    curl -u elastic -X PUT "$ES_URL/_security/user/wagtail" \
      -H 'Content-Type: application/json' \
      -d '{"password": "GENERATED PASSWORD HERE", "roles": ["wagtail"], "full_name": "Wagtail"}'
    ```

!!! info "Multiple deployments"
    Deployments that share a cluster must not share a user or an index prefix. Give each one its own `ES_INDEX_PREFIX`, role, and user, and set the user with `global.elasticsearch.username`.

### Store the password
The password is read from AWS Secrets Manager by an `ExternalSecret`.

1. Create a secret named `dev/ov/elasticsearch`, or use another name and set `global.elasticsearch.externalSecretsKey`. It needs one key:

    | Key           | Value                                  |
    | ------------- | -------------------------------------- |
    | `ES_PASSWORD` | The password from the previous section |

2. Enable the `ExternalSecret` in the Helm values:

    ```yaml
    global:
      elasticsearch:
        username: wagtail
        # externalSecretsKey: dev/ov/elasticsearch
    app-template:
      rawResources:
        es-secrets:
          enabled: true
    ```

The `ExternalSecret` creates a secret named `<release>-es-secrets`. The backend and the `update-index` job read it, and its `ES_PASSWORD` overrides any `ES_PASSWORD` in the backend secret.

### Verify
Check that the user can authenticate and see its indices:

```bash
curl -u wagtail "$ES_URL/_security/_authenticate"
curl -u wagtail "$ES_URL/_cat/indices/ov_*?v"
```

Then rebuild the index from the backend and make sure it completes without errors:

```bash
kubectl exec deploy/RELEASE-backend -- python manage.py update_index
```

## Authentication
Editors, moderators, and admins sign in to the Wagtail admin with [Authentik](https://goauthentik.io) over OpenID Connect. The Authentik application, provider, groups, and access rules are declared as a [blueprint](https://docs.goauthentik.io/customize/blueprints/) in the `authentik` chart of [cluster-deploy](https://github.com/WGBH-MLA/cluster-deploy), not in this chart.

### Configure the deployment
1. Add the client secret to the backend secret in AWS Secrets Manager (`dev/ov/backend`, or `global.backend.externalSecretsKey`). The Authentik blueprint reads the same entry, so both sides always agree:

    | Key                  | Value                                                       |
    | -------------------- | ----------------------------------------------------------- |
    | `OIDC_CLIENT_SECRET` | A long random string, for example `openssl rand -base64 48` |

2. Point the release at its Authentik instance. The defaults match the dev instance, so only other environments need this:

    ```yaml
    global:
      auth:
        url: https://auth.wgbh-mla.org
        # clientId: openvault
        # slug: openvault
    ```

The chart passes `OIDC_SERVER_URL` and `OIDC_CLIENT_ID` to the backend. The callback URL is `https://<host>/accounts/oidc/authentik/login/callback/`, and the Authentik blueprint must list it for each environment.

### Grant access
Add the user to one of these groups in Authentik. Only members of these groups can sign in, and the backend grants the matching Wagtail access each time they do:

| Authentik group | Wagtail access                                                       |
| --------------- | -------------------------------------------------------------------- |
| `ov-editors`    | The built-in **Editors** group: add and edit pages                   |
| `ov-moderators` | The built-in **Moderators** group: add, edit, and **publish** pages  |
| `ov-admins`     | Superuser                                                            |

Access is only ever granted at sign-in, never removed. Taking someone out of a group stops them signing in, but any Wagtail access they already have stays until you remove it in Wagtail. A user who signs in with the same email as an existing Wagtail user is linked to that user.

### Verify
Open `/admin/login/`, choose **Sign in with Authentik**, and check that the browser returns to `/admin/`. In Authentik, **Customization > Blueprints** should show the `Open Vault` blueprint as successful.
