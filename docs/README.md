# Open Vault Deployment Docs

This is the documentation website generator for ov-deploy, built with [MkDocs](https://www.mkdocs.org/) and the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

## Dev

```sh
uv sync
uv run mkdocs serve
```

## Build

```sh
uv run mkdocs build
```

## Deploy
Changes to the `docs/` folder will automatically deploy to GitHub Pages via the docs Action workflow in `.github/workflows/docs.yml`.

```yaml
name: docs
on:
  pull_request:
    branches:
      - main
    paths:
      - docs/**
  push:
    branches:
      - main
      - docs
    paths:
      - docs/**
  workflow_dispatch:
  
  ...
  ```

Deployments will be triggered on:
- Pushes to `main` or `docs` branches that modify files in the `docs/` folder
- Pull requests to `main` that modify files in the `docs/` folder
- Manual dispatch

## Versioning
The documentation site uses [mike](https://mike.readthedocs.io/en/latest/) for versioning.

### List Versions
To see the available versions, run:

```sh
uv run mike list
```
### Create New Version
To create a new version of the docs, run the `docs-version` script:

```sh
uv run ./scripts/docs-version.sh <new-version>
```

This will create a new version of the docs, build it, and deploy it to the `gh-pages` branch.
