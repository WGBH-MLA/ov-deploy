# Development

For deploying on a single machine with `docker compose`

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
  deploy           run a ./deploy command
  i | init         run initialization script
  h | help         prints this help text
  m | manage       run a wagtail manage.py command
  restore | load   restore a database backup
  s | shell        run a django shell command with the app context
```

## Development Environment

Run the development environment, with `docker compose`:

```bash
./ov dev
```

Or, simply:

```bash
./ov d
```
