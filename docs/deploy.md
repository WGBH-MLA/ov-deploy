# Deployment

## General

Production deployments are run in a Kubernetes cluster, using images built by our CI/CD pipeline. The deployment is managed by [Argo-CD](https://argoproj.github.io/argo-cd/), which is configured to watch the `main` branch of the `ov-deploy` repository for changes.

When a change is detected, Argo-CD will pull the latest configuration from the repository, and apply it to the cluster.

!!! kube "Setup"

    If you haven't set up a production environment, follow the steps in [Setup](setup.md#production) first.

### Resources
Each component of the stack is deployed as a set of Kubernetes resources. They consist of:

#### Deployment
A deployment is a set of pods, which are the actual running containers. The deployment manages the pods, and ensures that the desired number of pods are running at all times.

#### Service
A service is a network endpoint that can be accessed by other pods. It is used to expose a deployment as a named endpoint, which can be accessed by other pods in the cluster.

#### Ingress
An ingress is a network endpoint that can be accessed by external clients. It is used to expose a service as a named endpoint, which can be accessed by clients outside the cluster.

!!! kube "Traefik"
    We use [Traefik](https://traefik.io/solutions/kubernetes-ingress/) as our ingress controller, which is configured to route incoming requests to the appropriate service. It also handles SSL termination, and redirects HTTP requests to HTTPS.

#### ConfigMap
A config map is a set of key-value pairs that can be accessed by pods. It is used to store configuration values that are needed by the pods.

#### Secret
A secret is a secure set of key-value pairs that can be accessed by pods. It is used to store sensitive configuration values that are needed by the pods.

## Deployments

Using Argo-CD, create the following deployments:

### Backend
Using Argo-CD, deploy the backend to the cluster

```yml
Namespce: ov
Repo_Url: https://github.com/WGBH-MLA/ov-deploy
Path: ov-wag
Branch: main
```

### Initial Migration

With a new database and user configured, SSH into the `ov-wag` pod and run the initial migration:

```bash
ov m migrate
```

### Frontend
Using Argo-CD, deploy the backend to the cluster

```yml
Namespce: ov
Repo_Url: https://github.com/WGBH-MLA/ov-frontend
Path: ov-frontend
Branch: main
```

## Management
Some common management tasks are described below.

### Update image
Deployment images can be changed simply by changing the image tag in the deployment configuration.

Images are built from each PR to `main`, as well as pushes to `main`. To deploy a specific PR, simply change the image tag to the PR number.

```yml title="Change backend image to PR#123"
      image: ghcr.io/wgbh-mla/ov-wag:pr-123
```

To use the latest production image, change the image tag to `main`.

```yml title="Change backend image to main"
      image: ghcr.io/wgbh-mla/ov-wag:main
```

!!! kube "Change image using `kubectl`"
    This can also be done directly with `kubectl`:


    ```bash title="set backend version to PR#123"
    kubectl set image deployment.apps/ov-wag ov-wag=ghcr.io/wgbh-mla/ov-wag:pr-123
    ```

### Scale deployment
To scale a deployment, simply change the `replicas` value in the deployment configuration.

```yml title="Scale backend to 3 replicas"
  replicas: 3
```

### Update configuration
To update the configuration of a deployment, simply change the value in the deployment configuration.

```yml title="Change backend configuration"
        - name: OV_DB_PASSWORD
          value: NEW POSTGRES PASSWORD HERE
```
