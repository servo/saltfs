#!/usr/bin/env python3

import importlib
import os
import sys

from tests.util import color, GREEN, RED, Failure, project_path


def is_python_script(dir_entry):
    return dir_entry.name.endswith('.py') and dir_entry.is_file()


def run_tests(tests):
    any_failures = False

    for test_spec in tests:
        test_dir = os.path.join(project_path(), 'tests', *test_spec.split('.'))

        python_scripts = filter(is_python_script, os.scandir(test_dir))
        tests = sorted([entry.name for entry in python_scripts])

        for test in tests:
            test_mod_name = 'tests.{}.{}'.format(test_spec, test[:-3])
            test_mod = importlib.import_module(test_mod_name)
            if not hasattr(test_mod, 'run'):  # Not a test script
                continue

            try:
                result = test_mod.run()
            except Exception as e:
                message = 'Test \'{}\' raised an exception:'.format(test)
                result = Failure(message, str(e))

            if result.is_success():
                print('[ {} ] {}'.format(color(GREEN, 'PASS'), result.message))
            else:
                any_failures = True
                print('[ {} ] {}'.format(color(RED, 'FAIL'), result.message))
                for line in result.output.splitlines():
                    print('         {}'.format(line))

    return 1 if any_failures else 0


def main():
    if sys.version_info < (3, 5):  # We use features introduced in Python 3.5
        sys.stderr.write('{}: Python 3.5 or later is needed for this script\n'
                         .format(__file__))
        return 1

    tests = ['lint']  # Only tests that are always safe and meaningful to run
    if len(sys.argv) > 1:
        tests = sys.argv[1:]

    return run_tests(tests)


if __name__ == '__main__':
    sys.exit(main())
