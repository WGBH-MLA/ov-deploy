## Requirements

On your local machine, you will need:

- `docker`
- `kubectl`

!!! auth "Authorization"

      In addition to the software requirements, in order to manage the deployment stack, you will need:

      - Authorization to push docker images to `wgbhmla` Dockerhub account.
      - Access to the GBH VPN

##### _TODO: Add doc on how to verify that you have all these dependencies, and if not, how to get them._

## Concepts

The following are some definitions for some of the terms used below:

### Production

: The fully deployed stack, publicly available to all clients

### Demo / Staging

: A separate production stack, used to test changes and maintain a live working backup.

: This will be available on a different domain than the production stack

### Pod

: A single instance of a running docker image.

### Namespace

: The name of the kubrenetes context to deploy.

: Currently, this must be one of:

: - `openvault`
: - `ov-demo`

## Deployment

"Production" and "Demo" deployments are in Kubernetes on AWS. The workloads consist of "pods", which are Docker containers, and those containers are run using Docker images that we've pushed to Dockerhub. These docker images come from the Dockerfiles of the `ov-frontend` and `ov-wag` repositories.

Generally speaking, the deployment process consists of the following tasks:

- Checkout the desired versions of `ov-frontend` and `ov-wag` source code.
- Build Docker images from the Dockerfiles within the specific versions of `ov-frontend` and `ov-wag`.
- Push the Docker images to Dockerhub.
- Update the workloads in Kubernetes to use the updated Docker images.

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


!!! abstract "OV_*_VERSION"
    The versions of `ov-wag` and `ov-frontend` repositories will be used in several of the following commands, so the following commands are documented with the `$OV_WAG_VERSION` and `$OV_FRONTEND_VERSION` variables. You can set these in your session by using `export`

     ``` bash title="Export OV_*_VERSION"
     export OV_WAG_VERSION=[tag|branch|commit]
     export OV_FRONTEND_VERSION=[tag|branch|commit]
     ```
After [checking out the code](/setup#0-checkout-code):

#### Build images

1. Set the `ov-wag` submodule to the tag, branch, or commit that you want to deploy.
``` bash title="Checkout backend"
cd ov-wag
git checkout $OV_WAG_VERSION
cd ..
```

1. Set the `ov-frontend` submodule to the tag, branch, or commit that you want to deploy.
```bash title="Checkout frontend"
cd ov-frontend
git checkout $OV_FRONTEND_VERSION
cd ..
```

1. Build Docker images.
``` bash title="Build docker images"
docker build -t wgbhmla/ov-wag:$OV_WAG_VERSION --target production ./ov-wag
docker build -t wgbhmla/ov-frontend:$OV_FRONTEND_VERSION --target production ./ov-frontend
```
: !!! note "TODO: change build from 'production' to 'deployment'?"
    This would require a change to Dockerfile in ov-wag repo, but would be less confusing since the image may end up in either Production or Demo environments.
#### Push images
1. Login to docker hub
``` bash title="docker login"
docker login --username wgbhmla
```

1. Push newly built images to Docker Hub
``` bash title="push images"
docker push wgbhmla/ov-wag:$OV_WAG_VERSION
docker push wgbhmla/ov-frontend:$OV_FRONTEND_VERSION
```
: !!! auth "Passwords"
        The password for Docker Hub user `wgbhmla` is in [passwordstate](https://lph.wgbh.org/).

#### Update Kubernetes workloads
There several ways of updating the kubrenetes workflow:
- Rancher web interface
- `kubectl` commands

!!! abstract
    The `./deploy` script is designed to execute the necessary `kubectl` commands from an authorized device. It


##### Using the Rancher web interface
: !!! note "TODO: needs more affirming feedback"
        Go through steps to ensure consistency

  1. Log in to GBH VPN using Cicso AnyConnect.
  1. Go to https://rancherext.wgbh.org/login and click "Log In with Azure ID".
  1. From the leftmost item in the top menu, select the "MLA" project, which is indicated as being in the cluster named "digital-eks-dev".
  1. Beneath the top menu are several tabs: "Workloads", "Load Balancing", "Service Discovery", and "Volumes". Select "Workloads" if it is not already selected.
  1. Locate the row identifying the "ov" workload under the table heading that says "Namespace: openvault".
  1. Go to https://rancherext.wgbh.org
  1. In the top menu, click on the "digital-eks-dev", then click the "MLA" project name.

 1. Locate the workload
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
  --ov-wag-version=v1.1.0 \
  --ov-frontend-version=v2.2.0 \
  # optional params, values shown are defaults
  --ov-wag-env=./ov-wag/env.yml \
  --ov-wag-secrets=./ov-wag/secrets.yml \
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
