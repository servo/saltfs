import os

RED = 31
GREEN = 32
BLUE = 34
MAGENTA = 35


def color(code, string):
    return '\033[' + str(code) + 'm' + string + '\033[0m'


def display_path(path):
    return color(MAGENTA, path)


def colon():
    return color(BLUE, ':')


EXCLUDE_DIRS = ['.git', '.vagrant']


def project_path():
    abspath = os.path.realpath(os.path.join(os.getcwd(), __file__))
    # One dirname for tests dir, another for project dir
    project_dir = os.path.dirname(os.path.dirname(abspath))
    return os.path.relpath(project_dir)


def paths():
    for root, dirs, files in os.walk(project_path(), topdown=True):
        for exclude_dir in EXCLUDE_DIRS:
            if exclude_dir in dirs:
                dirs.remove(exclude_dir)

        for filename in files:
            yield os.path.join(root, filename)


class TestResult(object):
    pass


class Success(TestResult):
    def __init__(self, message):
        self.message = message

    def is_success(self):
        return True

    def is_failure(self):
        return False


class Failure(TestResult):
    def __init__(self, message, output):
        self.message = message
        self.output = output

    def is_success(self):
        return False

    def is_failure(self):
        return True
