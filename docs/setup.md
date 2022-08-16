# Setup

## Development

The following steps describe the setup process for local development. For production setup, see [Production](#production)

### 0. Checkout code

Clone the source code from github, including submodules:

```bash
git clone --recurse-submodules https://github.com/WGBH-MLA/ov-deploy.git
```

Change into the new `ov-deploy` directory

```bash
cd ov-deploy
```

???+ abstract "Initialize and update submodules"

    If the repository was cloned without the submodules, they will need to be initialized first.
    ```bash
    git submodule init
    git submodule update
    ```

???+ abstract "Checkout code"

    If running a version other than the `main` branch, you will need to checkout the code first, and update the git submodules.

    Usually this will be a tag or a branch. For example, if checking out `v0.2.0`:

    ```bash
    git checkout v0.2.0
    git submodule update
    ```

### 1. Create the database secrets file

In `ov-wag`, create a file called `.db` with the following contents:

```bash title="ov-wag/.db"
POSTGRES_PASSWORD="YOUR POSTGRES PASSWORD HERE"
```

??? note "Generating a password"

    This command will generate a new password config file and save it to `ov-wag/.db`

    ##### **:warning: WARNING:** This will overwrite any existing password stored in the `.db` file! **:warning:**
    Run this command from the top level `ov-deploy/` directory.
    ```bash
    echo "POSTGRES_PASSWORD=$(openssl rand -base64 24)" > ov-wag/.db
    ```

### 2. Create the backend secrets file

In `ov-wag`, create a file called `.env` with the following contents:

```bash title="ov-wag/.env"
OV_DB_ENGINE=django.db.backends.postgresql
OV_DB_PORT=5432
OV_DB_NAME=postgres
OV_DB_USER=postgres
OV_DB_PASSWORD="YOUR POSTGRES PASSWORD HERE"
```

### 3. Run initialization script

```bash
./ov init
```

???+ abstract "`./ov init` script"

    This is the equivalent of running:

    ```bash

    ./ov build # (1)

    ./ov c run -it front npm install # (2)
    ```

    1. build docker files
    1. install npm requirements

## Production

If deploying for the first time, Kubernetes must be configured to receive deployments. If this has already been done, you can skip this section.

!!! auth "Login"

    1. Login to VPN
    1. [Login to Rancher](https://rancherext.wgbh.org/login) ("Log in with Azure ID")
    1. [Go to MLA project](https://rancherext.wgbh.org/p/c-7qk7g:p-lpkts/workloads)

### Create namespace

!!! todo "TODO: elaborate"

### Create workloads

For each workload:

1.  From the Workloads tab of the project, Click `Deploy`
1.  Enter the name of the service

    !!! note "Service name"

        If using the automatic `deploy` script, the name of the service must exactly match the name of the docker hub image

1.  Set the Docker image to: `[DOCKERHUB ACCOUNT NAME]/[DOCKER IMAGE NAME]:[TAG]`

    - For example: `wgbhmla/ov-wag:latest`

1.  Set environment variables

    Create a new config map with the necessary environment variables.

    `Resources > Config > Add Config Map`

    ```bash title="ov-wag-config"
    OV_DB_ENGINE=django.db.backends.postgresql
    OV_DB_PORT=5432
    OV_DB_NAME=postgres
    OV_DB_USER=postgres
    ```

    Click `Add From Source` and set `type: Config Map`

    Select the name of the config map

1.  Enter secrets

    Add a new secret with any secrets that need to be available.

    Click `Add From Source` and set `type: Secret`

    ```bash title="ov-wag-secret"
    OV_DB_PASSWORD=p@ssW0rd!
    ```

!!! todo "TODO: Enumerate kube steps"

    Enumerate the minimum steps required to get Kubernetes setup up in Rancher to handle deployments.

### Workloads

The following services are needed to run the stack:

#### db

- image: `postgres:14.2-alpine`
- secrets:

      ```bash title="db secrets"
      POSTGRES_PASSWORD=p@ssW0rd!
      ```

#### ov-wag (backend)

- image: `wgbhmla/ov-wag`
- config:

      ```bash title="ov-wag environment"
      OV_DB_ENGINE=django.db.backends.postgresql
      OV_DB_PORT=5432
      OV_DB_NAME=postgres
      OV_DB_USER=postgres
      ```

- secrets:

      ```bash title="ov-wag.secrets"
      OV_DB_PASSWORD=p@ssW0rd!
      ```

#### ov-frontend

- image: `wgbhmla/ov-frontend`
- config:

      ```bash title="ov-frontend environment"
      OV_API_URL=ov-wag
      ```

#### ov-nginx

- image: `wgbhmla/ov-nginx`

      - preconfigured with `nginx.conf`
      - proxy pass to `http://ov-frontend:3000`

- endpoints:

      - `80/http`

- Load Balancing:

      - hostname: `[public url]`

#### jumpbox

- image: `wgbhmla/jumpbox`