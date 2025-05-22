# Deployments

!!! kube "Setup"

    If you haven't set up a production environment, follow the steps in [Setup](setup.md#production) first.

## Helm
The recommended way to deploy Open Vault is using the Helm Chart.

### Install
Add the Helm repository:
```sh
helm repo add ov https://wgbh-mla.github.io/ov-deploy
```

Update the charts:
```sh
helm repo update
```

Customize the values in `values.yaml` to your needs. You can also use `--set` to override values on the command line.
```yaml
global:
  backend:
    image:
      tag: latest
```

Install the Helm chart:
```sh
helm install ov ov/openvault
```

### Upgrade
```sh
helm upgrade ov ov/openvault
```