import os
import subprocess

from tests.util import Failure, Success, project_path


def run():
    CONF_DIR = os.path.join(project_path(),
                            'buildbot', 'master', 'files', 'config')
    # Have to specify master.cfg separately because it is not a .py file
    command = ['flake8', CONF_DIR, os.path.join(CONF_DIR, 'master.cfg')]
    ret = subprocess.run(command,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE,
                         universal_newlines=True)

    if ret.returncode == 0:
        return Success("Buildbot master config passed linting")
    else:
        return Failure("Buildbot master config lint check failed:", ret.stdout)
