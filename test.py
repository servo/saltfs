#!/usr/bin/env python3

import importlib
import os
import sys

from tests.util import color, GREEN, RED, Failure, project_path


def is_python_script(path):
    return path.endswith('.py')


def main():
    if sys.version_info < (3, 5):  # We use features introduced in Python 3.5
        sys.stderr.write('{}: Python 3.5 or later is needed for this script\n'
                         .format(__file__))
        return 1

    ANY_FAILURES = False

    test_dir = os.path.join(project_path(), 'tests')
    tests = sorted(filter(is_python_script, os.listdir(test_dir)))
    for test in tests:
        test_mod = importlib.import_module('tests.{}'.format(test[:-3]))
        if not hasattr(test_mod, 'run'):  # Not a test script
            continue

        try:
            result = test_mod.run()
        except Exception as e:
            result = Failure('Test \'{}\' raised an exception:'.format(test),
                             str(e))

        if result.is_success():
            print('[ {} ] {}'.format(color(GREEN, 'PASS'), result.message))
        else:
            ANY_FAILURES = True
            print('[ {} ] {}'.format(color(RED, 'FAIL'), result.message))
            for line in result.output.splitlines():
                print('         {}'.format(line))

    return 1 if ANY_FAILURES else 0

if __name__ == '__main__':
    sys.exit(main())
