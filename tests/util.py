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
    # One dirname for tests dir, another for project dir
    project_dir = os.path.dirname(os.path.dirname(__file__))
    common = os.path.commonpath([project_dir, os.getcwd()])
    return project_dir.replace(common, '.', 1)  # Only replace once


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

    def __str__(self):
        return '[ {} ] {}'.format(color(GREEN, 'PASS'), self.message)


class Failure(TestResult):
    def __init__(self, message, output):
        self.message = message
        self.output = output

    def is_success(self):
        return False

    def is_failure(self):
        return True

    def __str__(self):
        output = ['[ {} ] {}'.format(color(RED, 'FAIL'), self.message)]
        for line in self.output.splitlines():
            output.append('         {}'.format(line))
        return '\n'.join(output)


def format_nested_failure(failure):
    output = ['- {}'.format(failure.message)]
    output += ['  {}'.format(line) for line in failure.output.splitlines()]
    return '\n'.join(output)
