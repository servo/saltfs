import subprocess

from tests.util import Failure, Success


def run():
    command = ['sudo',  # To get access to buildbot files owned by servo
               'buildbot', 'checkconfig', '/home/servo/buildbot/master']
    ret = subprocess.run(command,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE,
                         universal_newlines=True)

    if ret.returncode == 0:
        return Success("Buildbot master config passed checkconfig")
    else:
        return Failure("Buildbot master config check failed:", ret.stderr)
