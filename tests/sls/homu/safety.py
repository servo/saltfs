import subprocess

from tests.util import Failure, Success


def run():
    pip_proc = subprocess.Popen(
        ['/home/servo/homu/_venv/bin/pip', 'freeze'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    safety_proc = subprocess.Popen(
        ['safety', 'check', '--full-report', '--stdin'],
        stdin=pip_proc.stdout,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        universal_newlines=True
    )
    pip_proc.stdout.close()
    stdout, _ = safety_proc.communicate()

    if safety_proc.returncode != 0:
        return Failure(
            'Insecure Python packages installed in Homu env:', stdout
        )

    return Success('No insecure Python packages found in Homu env')
