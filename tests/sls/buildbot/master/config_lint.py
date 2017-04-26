import os
import subprocess

from tests.util import Failure, Success, project_path


def run():
    CONF_DIR = os.path.join(
        project_path(),
        'buildbot',
        'master',
        'files',
        'config'
    )
    # Have to specify master.cfg separately because it is not a .py file
    command = ['flake8', CONF_DIR, os.path.join(CONF_DIR, 'master.cfg')]
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    stdout, _ = proc.communicate()

    if proc.returncode != 0:
        return Failure("Buildbot master config lint check failed:", stdout)

    return Success("Buildbot master config passed linting")
