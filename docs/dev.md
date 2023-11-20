# Development

This page describes how to run the development environment on a machine with `docker compose`.

???+ abstract "Requirements"

    - [docker](https://docs.docker.com/get-docker/)
    - [docker compose](https://docs.docker.com/compose/install/)

    Running the services outside of docker is possible, but not supported in this context.

## ./ov

The `ov` file is the primary Open Vault command line script. This contains a number of pre-built commands to do basic operations

### Usage

`./ov COMMAND [args]`

```bash title="./ov --help"
COMMANDS:

  b | build        build the docker images
  backup | dump    create a backup of the database
  c | cmd          run a compose command
  d | dev          start a development server
  deploy           run a ./deploy command
  i | init         run initialization script
  h | help         prints this help text
  m | manage       run a wagtail manage.py command
  restore | load   restore a database backup
  s | shell        run a django shell command with the app context
```

### Commands

#### `b` | `build`

: Build the docker images locally.

!!! abstract "build a single image"

    Additional docker arguments can be passed to this command.

    For example, to build only a single image:

    ```bash title="Build frontend"
    ./ov b front
    ```

#### `backup` | `dump`

: Create a database dump file with the timestamp as the filename.

#### `c` | `cmd`

: Run a `docker compose` command with the base config files in place.

#### `d` | `dev`

: Run Development Environment

: Run the development environment, with `docker compose`, and follow container logs.

!!! abstract "Compose arguments"

    Additional compose arguments can be passed. For example, to rebuild the containers before running:

    ```bash
    ./ov d --build
    ```

#### `deploy`

: Shortcut for `./deploy [command]`.

: See [Deploy](deploy.md) for detailed usage.

#### `docs`

: Build and run the documentation server, with live change reloading.

#### `i` | `init`

: Initialize a development environment.

: See [Setup](setup.md) for detailed instructions.

#### `m` | `manage`

: Run a `manage.py` command in the docker context.

#### `restore`

: Restore the database with a backup.

```bash title="restore db"
./ov restore db_backup.sql
```

#### `s` | `shell`

: Enter into a python django shell interpreter, with the application context loaded.

## Examples

The following are some useful examples of development commands that might be run:

### Migrate database

Generating the migration files can be accomplished with:

```bash
./ov m makemigrations
```

To Run the database migrations:

```bash
./ov m migrate
```

### Show the logs

Show the docker compose logs
`./ov c logs`

Show logs for just the frontend
`./ov c logs ov-frontend`
