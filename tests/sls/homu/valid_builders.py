import json
import os.path
import subprocess
import toml

from tests.util import Failure, Success


def run():
    homu_cfg = toml.load('/home/servo/homu/cfg.toml')
    homu_builders = homu_cfg['repo']['servo']['buildbot']

    # We need to invoke a new process to read the buildbot master config
    # because buildbot is written in python2.
    scriptpath = os.path.join(os.path.dirname(__file__), 'get_buildbot_cfg.py')
    ret = subprocess.run(
        ['/usr/bin/python2', scriptpath],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    if ret.returncode != 0:
        return Failure(
            'Unable to retrieve buildbot builders name:', ret.stderr
        )

    buildbot_builders = json.loads(ret.stdout.decode('utf-8'))['builders']

    for buildertype in ['builders', 'try_builders']:
        diff = set(homu_builders[buildertype]) - set(buildbot_builders)
        if diff:
            return Failure(
                "Homu {} config isn't synced with buildbot config"
                .format(buildertype),
                'Difference: {}'.format(diff)
            )

    return Success('Buildbot and homu configs are synced')
