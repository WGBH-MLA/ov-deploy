# Manual deployment

In the event that an automated deployment fails you can do a step-by-step deployment to help debug problems.

## Requirements

On your local machine, you will need:

- [docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

!!! auth "Authorization"

      In addition to the software requirements, in order to manage the deployment stack, you will need:

      - Authorization to push docker images to `wgbhmla` Dockerhub account.
      - Access to the GBH VPN

!!! todo "TODO: Verify dependencies"

    Add doc on how to verify that you have all these dependencies, and if not, how to get them._

!!! abstract "OV\_\*\_VERSION"

    The versions of `ov-wag` and `ov-frontend` repositories will be used in several of the following commands, so the following commands are documented with the `$OV_WAG_VERSION` and `$OV_FRONTEND_VERSION` variables. You can set these in your session by using `export`

     ``` bash title="Export OV_*_VERSION"
     export OV_WAG_VERSION=[tag|branch|commit]
     export OV_FRONTEND_VERSION=[tag|branch|commit]
     ```

After [setting up the repository](/setup#0-checkout-code):

## Steps

### Build images

1.  Set the `ov-wag` submodule to the tag, branch, or commit that you want to deploy.

    ```bash title="Checkout backend"
    cd ov-wag
    git checkout $OV_WAG_VERSION
    cd ..
    ```

1.  Set the `ov-frontend` submodule to the tag, branch, or commit that you want to deploy.

    ```bash title="Checkout frontend"
    cd ov-frontend
    git checkout $OV_FRONTEND_VERSION
    cd ..
    ```

1.  Build Docker images.

    ```bash title="Build docker images"
    docker build -t wgbhmla/ov-wag:$OV_WAG_VERSION --target production ./ov-wag
    docker build -t wgbhmla/ov-frontend:$OV_FRONTEND_VERSION --target production ./ov-frontend
    ```

!!! todo "TODO: change build from `production` to `deployment`?"

    This would require a change to Dockerfile in ov-wag repo, but would be less confusing since the image may end up in either Production or Demo environments.

### Push images

1.  Login to docker hub

    ```bash title="docker login"
    docker login --username wgbhmla
    ```

1.  Push newly built images to Docker Hub

    ```bash title="push images"
    docker push wgbhmla/ov-wag:$OV_WAG_VERSION
    docker push wgbhmla/ov-frontend:$OV_FRONTEND_VERSION
    ```

!!! auth "Passwords"

    The password for Docker Hub user `wgbhmla` is in [passwordstate](https://lph.wgbh.org/).

### Update Kubernetes workloads

There several ways of updating the Kubernetes workflow:

- `kubectl` commands
- Rancher web interface

!!! abstract "`./deploy`"

    The `./deploy` script is designed to execute the necessary `kubectl` commands from an authorized device. It

    See usage details in [Deploy](#automatic-deployment)

#### Using `kubectl`

1.  Set the context

    ```bash title="Set the kubectl context"
    kubectl config use-context openvault
    ```

1.  Set the app image deployment tag

    ```bash title="set backend version to v0.2.0"
    kubectl set image deployment.apps/ov-wag ov-wag=wgbhmla/ov-wag:v0.2.0
    ```

#### Using the Rancher web interface

!!! todo "TODO: needs more affirming feedback"

    Go through steps to ensure consistency

!!! auth "Login"

    1. Login to VPN
    1. [Login to Rancher](https://rancherext.wgbh.org/login) ("Log in with Azure ID")
    1. [Go to MLA project](https://rancherext.wgbh.org/p/c-7qk7g:p-lpkts/workloads)

1.  Select the `Workloads` tab, if it is not already selected.

    - Other tabs are: `Load Balancing`, `Service Discovery`, and `Volumes`.

1.  Locate "Namespace: openvault"
1.  Click on the row identifying the `ov-wag` workload
1.  Edit the `Docker Image` value to the desired `image:tag` combination
1.  Click `Save`

!!! todo "TODO: add where to check logs, get feedback on success/fail"

!!! todo "TODO: image pull policy"

    add details about "image pull policy" and make sure it's set correctly -- i think to 'always pull' or something

## Example workflow

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
```

!!! todo "TODO: clean manual script"

    qa testing ensues

    it works hooray!

    Now, do we branch/pr/merge

    manual deploy for now until continuous-deploy?

    Do we first deploy to prod to ensure it's working so that we can do a quick rollback without involving continuous deployment in case of error?

    Or, do we not check in anything? Deploy to prod, check it out, and we're done.
