# Deployment

## General

Deployments are run in Kubernetes on AWS. The workloads consist of `pods` (Docker containers) which runs images automatically built from GitHub Actions

These images are built from the `Dockerfile`s of the `ov-frontend` and `ov-wag` repositories.

!!! abstract "Setup"

    If you haven't set up a production environment, follow the steps in [Setup](setup.md#production) first.

### Deployment Process

Generally speaking, the deployment process consists of the following tasks:

- **Checkout** the desired versions of the image(s) to be built.
- **Build** Docker images from the `Dockerfile`s for each microservice.
- **Push** the Docker images to Dockerhub.
- **Update** the workloads in Kubernetes to use the updated Docker images.

The [./deploy](#deploy) script is the simplest way to create and deploy an image, and should work in most cases.

### Scenario #1: Redeploy an `ov_deploy` commit

These steps assume some `ov_deploy` commit should be pushed to some deployment environment, either `production` or `demo`.

Starting from a known `ov_deploy` commit or branch:

`git checkout [commit or branch]`

`git submodule update`

### Scenario #2: Custom code

In `ov-wag` and `ov-frontend`, checkout (or manually edit) the code in each repository.

#### 1. Build images

- Build all images:

  `./ov build`

- Build single image:

  `./ov build [image name]`

**_Note:_** Other custom commands can be passed into the

#### 2. Push to docker hub

(tag the image?)

`docker push [tag name]`

#### 3. Redeploy pods

Redeploy the pod(s)

- Rancher
- kubectl

## `./deploy`

The `./deploy` helper script is designed to automate the process of deploying known versions of parts or the whole stack. For any given pod, it will:

- Build the docker images
- Push the images to docker hub
- Set the version tag of each deployed image

### Usage

The script can be called with several arguments:

1.  Required options:

    : `-c context`

    !!! kube "TODO: kubectl context"

        To setup the kubectl context, see the [production setup documentation](setup.md#production)

1.  Optional deployments:

    : Backend: `-b VERSION`
    : Frontend: `-f VERSION`
    : Proxy: `-p VERSION`
    : Jumpbox: `-j VERSION`
    : db: `-d VERSION`

    Where each `VERSION` is one of:

    - a git tag
    - a git branch
    - a git commit

1.  Run command

    : Verify in console logs that job has completed successfully, or returned an error.

### Example

```bash title="Deploy v0.1.0 of backend and frontend"
./deploy -c openvault -b v0.1.0 -f v0.1.0
```
