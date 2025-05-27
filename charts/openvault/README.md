# Open Vault Helm Chart
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/openvault)](https://artifacthub.io/packages/search?repo=openvault)

This Helm chart deploys Open Vault on Kubernetes.

## Install
Add the Helm repository:
```sh
helm repo add ov https://wgbh-mla.github.io/ov-deploy
```

Update the charts:

```sh
helm repo update
```

Install the Helm chart:

Optional: Change `ov` to the name of your release.

```sh
helm install ov ov/openvault
```

## Docs
For more information on using this Helm chart, please refer to the [documentation](https://wgbh-mla.github.io/ov-deploy/latest/)
