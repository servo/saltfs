#!/usr/bin/env python

"""
Utility which stops a Buildbot daemon gracefully
and blocks until the daemon is stopped.
This is built-in to Buildbot but not exposed by default.
"""

from __future__ import absolute_import, print_function

import os
import sys

from buildbot.scripts import base, stop


USAGE = "usage: {} [ -h | --help | <buildbot_basedir> ]"


def main(argv):
    usage = USAGE.format(argv[0])

    if len(argv) != 2:
        print(usage, file=sys.stderr)
        return 1

    if argv[1] == "-h" or argv[1] == "--help":
        print(usage)
        return 0

    config = {
        'quiet': False,
        'clean': True,
        'basedir': os.path.abspath(argv[1]),
    }
    return stop.stop(config, wait=True)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
