from argparse import ArgumentParser


def cli():
    """parse CLI args"""
    parser = ArgumentParser(description='Manage Open Vault deployments')
    parser.add_argument(
        '-c',
        '--context',
        required=True,
        type=str,
        choices=['openvault', 'openvault-demo'],
        # TODO: elaborate. This is important and a bit complex.
        # It requires that your local ~/.kube/config have these two
        # contexts present and properly configured.
        help='the kubectl context to use in the deployment',
    )

    parser.add_argument(
        '-b',
        '--ov_wag',
        type=str,
        metavar='TAG|COMMIT|BRANCH|HEAD',
        help='version of the ov_wag headless CMS backend to be deployed',
    )

    parser.add_argument(
        '-f',
        '--ov-frontend',
        type=str,
        metavar='TAG|COMMIT|BRANCH|HEAD',
        help='version of the ov-frontend website to be deployed',
    )

    parser.add_argument(
        '-p',
        '--ov-nginx',
        action='store_true',
        help='rebuild and redeploy ov-nginx image',
    )

    parser.add_argument(
        '--ov_wag-env',
        type=str,
        metavar='PATH',
        default='./ov_wag/env.yml',
        help='path to environment file for ov_wag',
    )

    parser.add_argument(
        '--ov_wag-secrets',
        type=str,
        metavar='PATH',
        default='./ov_wag/secrets.yml',
        help='path to secrets file for ov_wag',
    )

    parser.add_argument(
        '--ov-frontend-env',
        type=str,
        metavar='PATH',
        default='./ov-frontend/env.yml',
        help='path to environment file for ov-frontend',
    )

    # Parses the command line args.
    return parser.parse_args()
