from subprocess import run as sub_run


def run(cmd: str):
    """Run a shell command
    - Error on non-zero exit code
    - Return output (if any) as decoded string
    """
    return sub_run(cmd, shell=True, capture_output=True, check=True).stdout.decode()


def get_pod_name(context: str, workload: str):
    """Return the name of the first pod running in the workload"""
    return (
        run(
            f'kubectl get pods -l workload.user.cattle.io/workloadselector="deployment-{ context }-{ workload }" -o name'
        )
        .strip()
        .split('\n')[0]
    )
