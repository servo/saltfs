import os
import stat

from .util import display_path, paths, Failure, Success


SHEBANG = """\
#!/usr/bin/env {}

"""

INTERPRETERS = {
    'py': 'python3',
    'sh': 'sh'
}


def is_executable(path):
    exec_bit = stat.S_IXUSR
    return exec_bit == (exec_bit & os.stat(path)[stat.ST_MODE])


def has_correct_header(path):
    extension = path.rpartition('.')[2]
    expected_header = SHEBANG.format(INTERPRETERS[extension])

    with open(path, 'r', encoding='utf-8') as file_to_check:
        header = file_to_check.read(len(expected_header))

    if header != expected_header:
        return False

    return True


def run():
    executables = filter(is_executable, paths())
    failures = list(filter(lambda e: not has_correct_header(e), executables))

    if len(failures) == 0:
        return Success("All executable shebangs are correct")
    else:
        output = '\n'.join([display_path(path) for path in failures])
        return Failure("Bad shebangs found in these files:", output)
