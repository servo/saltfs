import imp
import json
import os.path
import sys

BUILDBOT_MASTER_PATH = '/home/servo/buildbot/master/'

if __name__ == '__main__':
    sys.path.append(BUILDBOT_MASTER_PATH)

    config = imp.load_source(
        'config',
        os.path.join(BUILDBOT_MASTER_PATH, 'master.cfg')
    )

    for sched in config.c['schedulers']:
        if sched.name == 'servo-auto':
            out = {'builders': sched.builderNames}
            print(json.dumps(out))
            exit(0)

    sys.stderr.write('error: "servo-auto" scheduler not found\n')
    exit(1)
