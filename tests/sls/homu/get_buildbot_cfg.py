from __future__ import print_function

import imp
import json
import os.path
import sys

BUILDBOT_MASTER_PATH = '/home/servo/buildbot/master/'


def main():
    sys.path.append(BUILDBOT_MASTER_PATH)

    config = imp.load_source(
        'config',
        os.path.join(BUILDBOT_MASTER_PATH, 'master.cfg')
    )

    for sched in config.c['schedulers']:
        if sched.name == 'servo-auto':
            out = {'builders': sched.builderNames}
            print(json.dumps(out))
            return 0

    print('error: "servo-auto" scheduler not found', file=sys.stderr)
    return 1


if __name__ == '__main__':
    sys.exit(main())
