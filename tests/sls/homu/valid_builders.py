import json
import os.path
import subprocess
import toml

from tests.util import Failure, Success


def run():
    homu_cfg = toml.load('/home/servo/homu/cfg.toml')
    homu_builders = homu_cfg['repo']['servo']['buildbot']

    # We need to invoke a new process to read the Buildbot master config
    # because Buildbot is written in python2.
    scriptpath = os.path.join(os.path.dirname(__file__), 'get_buildbot_cfg.py')
    proc = subprocess.Popen(
        ['/usr/bin/python2', scriptpath],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    stdout, stderr = proc.communicate()

    if proc.returncode != 0:
        return Failure(
            'Unable to retrieve buildbot builders:', stderr
        )

    buildbot_builders = json.loads(stdout)['builders']

    failure_msg = ''
    for builder_set in ['builders', 'try_builders']:
        diff = set(homu_builders[builder_set]) - set(buildbot_builders)
        if diff:
            failure_msg += 'Invalid builders for "{}": {}\n' \
                .format(builder_set, diff)

    if failure_msg:
        return Failure(
            "Homu config isn't synced with Buildbot config:",
            failure_msg
        )

    return Success('Buildbot and homu configs are synced')
