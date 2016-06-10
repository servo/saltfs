import itertools
import re

from tests.util import *


def display_trailing_whitespace(whitespace):
    # Show trailing whitespace with printing characters and in red
    # To make it easy to see what needs to be removed
    replaced = whitespace.replace(' ', '-').replace('\t', r'\t')
    return color(RED, replaced)


def display_failure(failure):
    path, line_number, match = failure
    line = match.group(1) + display_trailing_whitespace(match.group(2))
    return display_path(path) + colon() + str(line_number) + colon() + line


def check_whitespace(path):
    CHECK_REGEX = re.compile(r'(.*?)(\s+)$')
    trailing_whitespace = []
    with open(path, 'r', encoding='utf-8') as file_to_check:
        try:
            for line_number, line in enumerate(file_to_check):
                line = line.rstrip('\r\n')
                match = CHECK_REGEX.match(line)
                if match is not None:
                    trailing_whitespace.append((path, line_number, match))
        except UnicodeDecodeError:
            pass  # Not a text (UTF-8) file
    return trailing_whitespace


def run():
    failures = list(itertools.chain(*map(check_whitespace, paths())))

    if len(failures) == 0:
        return Success("No trailing whitespace found")
    else:
        output = '\n'.join([display_failure(failure) for failure in failures])
        return Failure("Trailing whitespace found on files and lines:", output)
