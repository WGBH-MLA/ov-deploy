from pydantic import BaseModel
from utils import run

GITHUB_URL = 'https://github.com/WGBH-MLA/'
OV_WAG_URL = GITHUB_URL + 'ov-wag.git'
OV_FRONT_URL = GITHUB_URL + 'ov-frontend.git'
HUB_ACCOUNT = 'wgbhmla'


def build_image(repo_name, tag, src=''):
    """Build and tag docker image from a repo#tag"""
    run(f'docker build {src or repo_name} -t {HUB_ACCOUNT}/{repo_name}:{tag}')


def push_image(repo_name, tag):
    """Push a tagged docker image to hub.docker.com

    Requires the user to be logged in"""
    run(f'docker push {HUB_ACCOUNT}/{repo_name}:{tag}')


def update_workload(pod, tag):
    """Sets the backend pod image to the proper tag"""
    run(f'kubectl set image deployment.apps/{pod} {pod}={HUB_ACCOUNT}/{pod}:{tag}')


class KubeContext(BaseModel):
    """Sets the kubectl context before performing operations"""

    context: str

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_current_context()

    def set_current_context(self):
        """Switch to the specified kubectl context."""
        run(f'kubectl config use-context {self.context}')


class Deployer(KubeContext):
    """Deployer class

    Used for openvault deployment configuration
    """

    db: str = None
    ov_wag: str = None
    ov_wag_env: str = None
    ov_wag_secrets: str = None
    ov_frontend: str = None
    ov_frontend_env: str = None
    ov_nginx: str = None
    jumpbox: str = None

    def _deploy(self, repo_name, tag, src=''):
        """Deploy helper function

        Deploy an individual image from a repo and tag name"""
        build_image(repo_name, tag, src=src)
        push_image(repo_name, tag)
        update_workload(pod=repo_name, tag=tag)

    def deploy(self):
        """Deploy all

        Run the full deployer process using the current context"""
        print(f'Starting deployment using context "{self.context}"')

        if not any(
            [self.ov_wag, self.ov_frontend, self.ov_nginx, self.jumpbox, self.db]
        ):
            raise Exception(f'Nothing specified for deployment.')
        if self.ov_wag:
            self._deploy('ov-wag', self.ov_wag, src=f'{OV_WAG_URL}#{self.ov_wag}')
        if self.ov_frontend:
            self._deploy(
                'ov-frontend',
                self.ov_frontend,
                src=f'{OV_FRONT_URL}#{self.ov_frontend}',
            )
        if self.ov_nginx:
            self._deploy('ov-nginx', self.ov_nginx)
        if self.jumpbox:
            self._deploy('jumpbox', self.jumpbox)
        if self.db:
            run(f'kubectl set image deployment.apps/db db=postgres:{self.db}')

        print('Done!')
