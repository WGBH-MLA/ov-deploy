# Initial setup

## 0. (Prereq) Clone repository:
- Clone the source code from github:
``` bash
git clone https://github.com/WGBH-MLA/ov-deploy.git
```
- Change into the new `ov-deploy` directory
``` bash
cd ov-deploy
```
- Initilize and update the submodules
``` bash
git submodule init && git submodule update
```

## 1. Create the database secrets file

In `ov-wag`, create a file called `.db` with the following contents:
```bash title="ov-wag/.db"
POSTGRES_PASSWORD="YOUR POSTGRESS PASSWORD HERE"
```

??? note "Generating a password"

    This command will generate a new password config file and save it to `ov-wag/.db`

    ##### **:warning: WARNING:** This will overwrite any existing password stored in the `.db` file! **:warning:**
    Run this command from the top level `ov-deploy/` directory.
    ```bash
    echo "POSTGRES_PASSWORD=$(openssl rand -base64 24)" > ov-wag/.db
    ```

## 2. Create the backend secrets file

In `ov-wag`, create a file called `.env` with the following contents:

```bash title="ov-wag/.env"
OV_DB_ENGINE=django.db.backends.postgresql
OV_DB_PORT=5432
OV_DB_NAME=postgres
OV_DB_USER=postgres
OV_DB_PASSWORD="YOUR POSTGRESS PASSWORD HERE"
```

## 3. Run initialization script

```bash
./ov init
```

???+ abstract "`./ov init` script"

    This is the equivalent of running:

    ```bash

    git submodule init # (1)

    git submodule update # (2)

    ./ov build # (3)

    ./ov c run -it front npm install # (4)
    ```

    1. initialize submodule
    2. checkout current version
    3. build docker files
    4. install npm requirements
