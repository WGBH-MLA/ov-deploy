# ov_deploy

Deployment repository for Open Vault redesign

## Requirements
- `docker`
- `docker compose`

## Usage

### `./ov`

An init script is available with the following shortcut commands:

```bash
./ov COMMAND [args]

COMMANDS:

  c | cmd     run a compose command
  d | dev     start a development server
  h | help    prints this help text
  m | manage  run a wagtail manage.py command
  s | shell   run a django shell command with the app context
```

## Development
`./ov d`

## Production
