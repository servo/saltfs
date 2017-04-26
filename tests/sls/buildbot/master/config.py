import subprocess

from tests.util import Failure, Success


def run():
    command = [
        'sudo',  # To get access to buildbot files owned by servo
        'buildbot', 'checkconfig', '/home/servo/buildbot/master'
    ]
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    _, stderr = proc.communicate()

    if proc.returncode != 0:
        return Failure("Buildbot master config check failed:", stderr)

    return Success("Buildbot master config passed checkconfig")
