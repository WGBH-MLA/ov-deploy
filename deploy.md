# Deployment steps

## Prereqs
### On your local machine, you will need:

* Docker tools
  - `docker`
  - `docker-compose`
  - `kubectl`
* Access to the GBH VPN
* Authorization to push docker images to `wgbhmla` Dockerhub account.

_TODO: Add doc on how to verify that you have all these dependencies, and if not, how to get them._

## init

To deploy a new stack:

### 1. Create namespace in Rancher

Production: `openvault`
demo: `ov-demo`

### 2. Create pods

#### db

- image: `postgres:14.2-alpine`
- secrets:
  - `POSTGRES_PASSWORD`

#### ov (backend)

- image: `wgbhmla/ov_wag`
- config:
  - `ov_wag.config`
- secrets:
  - `OV_DB_PASSWORD`

#### ov-frontend

- image: `wgbhmla/ov-frontend`
- config:
  - `ov-frontend.config`

#### ov-nginx

- image: `foggbh/ov-nginx`
  - configured with `nginx.conf`
  - proxy pass to `http://ov-frontend:3000`
- ports:
  - `80/http`
- ingress:
  - hostname: `[url]`

#### jumpbox (optional utility kit)

- image: ?

## Redeploy

Redeployment steps for demo or production

### 0. Check out code

Set up the code to represent the state of the application you wish to redeploy.

#### Scenario #1: Redeploy an `ov_deploy` commit

These steps assume some `ov_deploy` commit should be pushed to some deployment environment, either `production` or `demo`.

Starting from a known `ov_deploy` commit or branch:

`git checkout [commit or branch]`

`git submodule update`

#### Scenario #2: Custom code

In `ov_wag` and `ov-frontend`, checkout (or manually edit) the code in each repository.

### 1. Build images

- Build all images:

  `./ov build`

- Build single image:

  `./ov build [image name]`

**_Note:_** Other custom commands can be passed into the

### 2. Push to docker hub

(tag the image?)

`docker push [tag name]`

### 3. Redeploy pods

Redeploy the pod(s)

- Rancher
- kubectl

## Deployment

"Production" and "Demo" deployments are in Kubernetes on AWS. The workloads consist of "pods", which are Docker containers, and those containers are run using Docker images that we've pushed to Dockerhub. These docker images come from the Dockerfiles of the `ov-frontend` and `ov_wag` repositories.

Generally speaking, the deployment process consists of the following tasks:
* Checkout the desired versions of `ov-frontend` and `ov_wag` source code.
* Build Docker images from the Dockerfiles within the specific versions of `ov-frontend` and `ov_wag`.
* Push the Docker images to Dockerhub.
* Update the workloads in Kubernetes to use the updated Docker images.

### Setting up Kubernetes in Rancher

If we are deploying for the first time, we need to configure Kubernetes to be able to receive deployments. If this has already been done, you can skip this section.

_TODO: enumerate the minimum steps required to get Kubernetes setup up in Rancher to handle deployments._

1. Log into VPN.
1. Go to https://rancherext.wgbh.org/login, and click "Login with Azure ID".
1. Go to MLA project (TODO: elaborate)
1. Create namespacde (TODO: elaborate)
1. Click "Deploy Workload"
1. Enter "ov" for Name field
1. Docker image: "[DOCKERHUB ACCOUNT NAME]/ov:latest"
1. Enter environment variables. **_TODO: elaborate on how._**
1. Enter secrets. **_TODO: elaborate on how._**

### Manual Deployment

In the event that an automated deployment fails you can do a step-by-step deployment to help debug problems.

1. Get the latest code from this repository.
   ```
   # skip this line if you've already cloned the repository
   git clone git@github.com:WGBH-MLA/ov_deploy.git
   cd ov_deploy
   git checkout main
   git pull
   ```

1. The versions of `ov_wag` and `ov-frontend` repositories will be used in several of the following commands, so to avoid typos, you can export the versions to environment variables, and use those environment variables in subsequent commands.
   ```
   export $OV_WAG_VERSION=[tag|branch|commit]
   export $OV_FRONTEND_VERSION=[tag|branch|commit]
   ```

1. Set the `ov_wag` submodule to the tag, branch, or commit that you want to deploy.
   ```
   cd ov_wag
   git checkout $OV_WAG_VERSION
   cd ..
   ```

 1. Set the `ov-frontend` submodule to the tag, branch, or commit that you want to deploy.
    ```
    cd ov-frontend
    git checkout $OV_FRONTEND_VERSION
    cd ..
    ```

1. Build Docker images.
   _TODO: change build from 'production' to 'deployment'? This would require a change to Dockerfile in ov_wag repo, but would be less confusing since the image may end up in either Production or Demo environments._

   _TODO: Build ov-nginx image._
   ```
   docker build -t wgbhmla/ov_wag:$OV_WAG_VERSION --target production ./ov_wag
   docker build -t wgbhmla/ov-frontend:$OV_FRONTEND_VERSION --target production ./ov-frontend
   ```

1. Push newly built images to Docker Hub
   ```
   # The password for Docker Hub user wgbhmla is in Passwordstate.
   docker login --username wgbhmla
   docker push wgbhmla/ov_wag:$OV_WAG_VERSION
   docker push wgbhmla/ov_wag:$OV_WAG_VERSION
   ```

1. Update Kubernetes workloads

   1. Using the Rancher web interface

      _TODO: needs more affirming feedback._

      1. Log in to GBH VPN using Cicso AnyConnect.
      1. Go to https://rancherext.wgbh.org/login and click "Log In with Azure ID".
      1. From the leftmost item in the top menu, select the "MLA" project, which is indicated as being in the cluster named "digital-eks-dev".
      1. Beneath the top menu are several tabs: "Workloads", "Load Balancing", "Service Discovery", and "Volumes". Select "Workloads" if it is not already selected.
      1. Locate the row identifying the "ov" workload under the table heading that says "Namespace: openvault".
      1. Go to https://rancherext.wgbh.org
      1. In the top menu, click on the "digital-eks-dev", then click the "MLA" project name.
      1.

   1. From the command line using `kubectl`

      _TBD_

   1. Locate the workoad
   1. Click the "Re-deploy"
      1. _TODO: add where to check logs, get feedback on success/fail_
      1. _TODO: add details about "image pull policy" and make sure it's set correctly -- i think to 'always pull' or something_



## TARGET WORKFLOW!
```
git clone git@github.com:WGBH-MLA/ov_deploy.git
cd ov_deploy
git ch -b test-new-versions-of-front-and-back-ends
./ov deploy \
  # required parameters \
  --namespace=openvault-demo \
  --ov_wag-version=v1.1.0 \
  --ov-frontend-version=v2.2.0 \
  # optional params, values shown are defaults
  --ov_wag-env=./ov_wag/env.yml \
  --ov_wag-secrets=./ov_wag/secrets.yml \
  --ov-frontend-env=./ov-frontend/env.yml \
# qa testing ensues
# it works hooray!
# Now, do we branch/pr/merge
# manual deploy for now until continuous-deploy?
# Do we first deploy to prod to ensure it's working so that we can
# do a quick rollback without involving continuous deployment in case of
# error?
# Or, do we not check in anything? Deploy to prod, check it out, and we're # done.
```
