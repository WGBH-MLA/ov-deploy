import os
from pydantic import BaseModel

OV_WAG_URL = 'https://github.com/WGBH-MLA/ov_wag.git'
OV_FRONTEND_URL = 'https://github.com/WGBH-MLA/ov-frontend.git'


class Deployer(BaseModel):
    """Deployer class

    Used for openvault deployment configuration
    """

    context: str
    ov_wag: str = None
    ov_wag_env: str = None
    ov_wag_secrets: str = None
    ov_frontend: str = None
    ov_frontend_env: str = None
    ov_nginx: bool = None

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_current_context()

    def set_current_context(self):
        """Switch to the specified kubectl context."""
        os.system(f'kubectl config use-context {self.context}')

    def build_ov_wag(self):
        """Build the backend ov_wag docker image"""
        os.system(f'docker build {OV_WAG_URL}#{self.ov_wag} -t {self.ov_wag_tag}')

    def build_ov_frontend(self):
        """Build the frontend ov-frontend docker image"""
        os.system(
            f'docker build {OV_FRONTEND_URL}#{self.ov_frontend} -t {self.ov_frontend_tag}'
        )

    def build_nginx(self):
        """Build the proxy nginx docker image"""
        os.system(f'docker build ov-nginx')

    def push_ov_wag(self):
        """Push the backend ov_wag docker image to hub.docker.com

        Requires the user to be logged in"""
        os.system(f'docker push {self.ov_wag_tag}')

    def push_ov_frontend(self):
        """Push the frontend ov-frontend docker image to hub.docker.com

        Requires the user to be logged in"""
        os.system(f'docker push {self.ov_frontend_tag}')

    def push_nginx(self):
        """Push the proxy nginx docker image to hub.docker.com

        Requires the user to be logged in"""
        os.system(f'docker push {self.ov_nginx_tag}')

    def update_ov_wag_workload(self):
        """Sets the backend pod image to"""
        os.system(f'kubectl set image deployment.apps/ov ov={self.ov_wag_tag}')

    def update_ov_frontend_workload(self):
        os.system(
            f'kubectl set image deployment.apps/ov-frontend ov-frontend={self.ov_frontend_tag}'
        )

    def deploy_ov_wag(self):
        """Deploy the backend"""
        print(f'Deploying ov_wag: "{self.ov_wag}"')
        self.build_ov_wag()
        self.push_ov_wag()
        self.update_ov_wag_workload()

    def deploy_ov_frontend(self):
        """Deploy the frontend"""
        print(f'Deploying ov-frontend: "{self.ov_frontend}"')
        self.build_ov_frontend()
        self.push_ov_frontend()
        self.update_ov_frontend_workload()

    def deploy_ov_nginx(self):
        """Deploy the proxy

        TODO: deploy proxy"""
        print(f'Deploying ov_nginx: "{self.ov_nginx}"')

    def deploy(self):
        """Run the deployment process using the current context"""
        print(f'Starting deployment using context "{self.context}"')

        if not any([self.ov_wag, self.ov_frontend, self.ov_nginx]):
            raise Exception(f'Nothing specified for deployment.')
        if self.ov_wag:
            self.deploy_ov_wag()
        if self.ov_frontend:
            self.deploy_ov_frontend()
        if self.ov_nginx:
            self.deploy_ov_nginx()

        print('Done!')

    @property
    def ov_wag_tag(self):
        return f'wgbhmla/ov_wag:{self.ov_wag}'

    @property
    def ov_frontend_tag(self):
        return f'wgbhmla/ov-frontend:{self.ov_frontend}'

    @property
    def ov_nginx_tag(self):
        return f'wgbhmla/ov-nginx:latest'
