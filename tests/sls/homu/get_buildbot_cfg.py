import imp
import json
import sys

if __name__ == '__main__':
    sys.path.append('/home/servo/buildbot/master/')

    config = imp.load_source(
        'config',
        '/home/servo/buildbot/master/master.cfg'
    )

    for sched in config.c['schedulers']:
        if sched.name == 'servo-auto':
            out = {'builders': sched.builderNames}
            print(json.dumps(out))
