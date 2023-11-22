# Deployments

Using Argo-CD, create the following deployments:

!!! kube "Setup"

    If you haven't set up a production environment, follow the steps in [Setup](setup.md#production) first.

### Backend
Deploy the backend to the cluster

```yml title="Backend deployment"
Namespce: ov
Repo_Url: https://github.com/WGBH-MLA/ov-deploy
Path: ov-wag
Branch: main
```

#### Initial Migration

With a new database and user configured, SSH into the `ov-wag` pod and run the initial migration:

```bash title="Apply database migrations"
ov m migrate
```

### Frontend
Deploy the frontend to the cluster

```yml title="Frontend deployment"
Namespce: ov
Repo_Url: https://github.com/WGBH-MLA/ov-frontend
Path: ov-frontend
Branch: main
```
