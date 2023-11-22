# Setup

## Prerequisites
These instructions assume you have the following:

- A working Kubernetes cluster
- `kubectl`, configured to connect to your cluster
- Argo-CD installed and configured
- Traefik installed and configured as an ingress controller
- A running PostgreSQL database

### Namespace
Create a new production namespace called `ov`:

```bash
kubectl create namespace ov
```

Set the current context to the new namespace:
```bash
kubectl config set-context --current --namespace=ov

# Verify the current context
kubectl config view --minify | grep namespace:
```

### Database
Create a new database called `ov` and a new user called `postgres` and a secure password.

```bash title="Database configuration"
POSTGRES_USER=postgres
POSTGRES_PASSWORD="YOUR POSTGRES PASSWORD HERE"
POSTGRES_DB=ov
```

??? note "Generating a password"

    This command will generate a new secure password:

    ```bash
    openssl rand -base64 24
    ```

    Increace the final number to increase the length and strength of the password.

### Secrets
Create the Backend secrets file

```bash title="ov-wag/secret.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: ov-wag-secret
  namespace: ov
stringData:
  OV_DB_PASSWORD: YOUR POSTGRES PASSWORD HERE
  OV_SECRET_KEY: RanDOmSeCrEtKeY_fOr_sESsion_cOOkies
  AWS_ACCESS_KEY_ID : # AWS IAM user access key
  AWS_SECRET_ACCESS_KEY: # AWS IAM user secret key
```

Apply this to the cluster:

```bash title="Apply secrets"
kubectl apply -f ov-wag/secret.yaml
```