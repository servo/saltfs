import subprocess

from tests.util import Failure, Success


def run():
    proc = subprocess.Popen(
        ['date'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    stdout, _ = proc.communicate()

    if proc.returncode != 0 or 'UTC' not in stdout:
        return Failure('Date is not in UTC: ', stdout)

    return Success('Date is in UTC')
