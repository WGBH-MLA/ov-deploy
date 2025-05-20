# Open Vault: Deploy
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/openvault)](https://artifacthub.io/packages/search?repo=openvault)

## About

Deployment documentation for the Open Vault project

## Links

- Site: [openvault.wgbh.org](https://openvault.wgbh.org)
- Documentation: [wgbh-mla.github.io/ov-deploy](https://wgbh-mla.github.io/ov-deploy/)
- Github: [github.com/WGBH-MLA/ov-deploy](https://github.com/WGBH-MLA/ov-deploy)

## Deploy

### Helm
The recommended way to deploy Open Vault is using Helm. This allows for easy upgrades and rollbacks, as well as a consistent deployment process.

```sh
helm repo add ov https://wgbh-mla.github.io/ov-deploy/
helm install ov ov/openvault
```

### docker-compose

#### TODO: Add instructions

## Credits

Developed by the [GBH Archives](https://wgbh.org/foundation/archives) at [GBH](https://wgbh.org)
