import subprocess

from tests.util import Failure, Success


def run():
    ret = subprocess.run(
        ['date'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    stdout = ret.stdout.decode('utf-8')

    if ret.returncode == 0 and 'UTC' in stdout:
        return Success('Date is in UTC')
    else:
        return Failure('Date is not in UTC: ', stdout)
