import os
import subprocess

from tests.util import Failure, Success, project_path


def run():
    paths = ['test.py', 'tests']
    paths = [os.path.join(project_path(), path) for path in paths]
    command = ['flake8'] + paths
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    stdout, _ = proc.communicate()

    if proc.returncode != 0:
        return Failure("Tests failed flake8 lint:", stdout)

    return Success("Tests passed flake8 lint")
