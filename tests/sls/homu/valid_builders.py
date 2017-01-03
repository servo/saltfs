import json
import os.path
import subprocess
import toml

from tests.util import Failure, Success


def are_builders_valid(buildbot, homu_cfg, buildertype):
    for builder in homu_cfg[buildertype]:
        if builder not in buildbot:
            diff = list(set(homu_cfg[buildertype]) - set(buildbot))
            diff_print = ''
            if len(diff) != 0:
                diff_print = 'Difference: {}'.format(diff)

            fail = Failure(
                'Homu "{}" config isn\'t sync with buildbot config'
                .format(buildertype),
                diff_print
            )

            return {
                'success': False,
                'value': fail
            }

    return {
        'success': True
    }


def get_script_path():
    dirname = os.path.dirname(__file__)
    return os.path.join(dirname, 'get_buildbot_cfg.py')


def run():
    homu_cfg = toml.load('/home/servo/homu/cfg.toml')
    homu_buildbot = homu_cfg['repo']['servo']['buildbot']

    ret = subprocess.run(
        ['/usr/bin/python2', get_script_path()],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    if ret.returncode != 0:
        return Failure(
            'Unable to retrieve buildbot builders name:', ret.stderr
        )

    buildbot_builders = json.loads(ret.stdout.decode('utf-8'))['builders']

    resp = are_builders_valid(buildbot_builders, homu_buildbot, 'builders')
    if not resp['success']:
        return resp['value']

    resp = are_builders_valid(buildbot_builders, homu_buildbot, 'try_builders')
    if not resp['success']:
        return resp['value']

    return Success('Buildbot and homu configs are synced')
