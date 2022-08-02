# About

## Stack
Open Vault is deployed as a number of seperate services, built into `docker` images, and orchestrated through `kubernetes`, using `Rancher`.

???+ abstract "Microservices vs macro application"
    While it is possible to run all services combined on a single physical or virtual instance, it is **strongly** recommended to run as a series of micro-services, which can be versioned and scaled independently.

    All documentation here will describe deployment through `docker` and `kubernetes`.

## Images

### `ov-frontend`
Frontend
### `ov-wag`
Backend
### `db`
Database
### `ov-nginx`
Proxy
### `jumpbox`
Utility
