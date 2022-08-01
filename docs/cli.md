# CLI

Command line scripts for deployment

## ./ov

Open Vault init script

## Requirements

- `docker`
- `docker compose`

## Usage

### `./ov COMMAND [args]`

```bash
COMMANDS:

  b | build        build the docker images
  backup | dump    create a backup of the database
  c | cmd          run a compose command
  d | dev          start a development server
  i | init         run initialization script
  h | help         prints this help text
  m | manage       run a wagtail manage.py command
  restore | load   restore a database backup
  s | shell        run a django shell command with the app context
```

## Initial setup

After cloning this repository:

1. Create the database `.db` secrets file

```bash
POSTGRES_PASSWORD="YOUR POSTGRESS PASSWORD HERE"
```

If you need to generate a password:

```bash
openssl rand -base64 16
```

2. Create the backend `.env` secrets file

```bash
OV_DB_ENGINE=django.db.backends.postgresql
OV_DB_PORT=5432
OV_DB_NAME=postgres
OV_DB_USER=postgres
OV_DB_PASSWORD="YOUR POSTGRESS PASSWORD HERE"
```

3. Run initialization script

```bash
./ov init
```

This is the equivelent of running:

```bash
# initialize submodule
git submodule init
# checkout current version
git submodule update
# build docker files
./ov build
# Insatll npm requirements
./ov c run -it front npm install
```

## Development Environment

Run the development environment:

```bash
./ov dev
```
