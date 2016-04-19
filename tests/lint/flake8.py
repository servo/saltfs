import os
import subprocess

from tests.util import Failure, Success, project_path


def run():
    paths = ['test.py', 'tests']
    paths = [os.path.join(project_path(), path) for path in paths]
    # Have to specify master.cfg separately because it is not a .py file
    command = ['flake8'] + paths
    ret = subprocess.run(command,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE,
                         universal_newlines=True)

    if ret.returncode == 0:
        return Success("Tests passed flake8 lint")
    else:
        return Failure("Tests failed flake8 lint:", ret.stdout)
