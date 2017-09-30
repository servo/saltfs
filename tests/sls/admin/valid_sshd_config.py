import subprocess

from tests.util import Failure, Success


def run():
    proc = subprocess.Popen(
        ['sshd', '-T', '-f', '/etc/ssh/sshd_config'],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    _, stderr = proc.communicate()

    if proc.returncode != 0:
        return Failure(
            'Invalid sshd_config file:', stderr
        )

    return Success('SSHD config file is valid')
