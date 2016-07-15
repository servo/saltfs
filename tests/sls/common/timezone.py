import subprocess

from tests.util import Failure, Success


def run():
    command = "date | grep -v UTC"
    ret = subprocess.run(command,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE,
                         universal_newlines=True,
                         shell=True)

    if ret.returncode == 1:
        return Success("Date is in UTC")
    else:
        return Failure("Date is not in UTC: ", ret.stdout)

