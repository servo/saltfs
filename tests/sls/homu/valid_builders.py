import json
import subprocess
import toml

from tests.util import Failure, Success


def is_builders_valid(buildbot, homu):
    for builder in homu:
        if builder not in buildbot:
            return False
    return True


def run():
    homu_cfg = toml.load('/home/servo/homu/cfg.toml')
    homu_buildbot = homu_cfg['repo']['servo']['buildbot']

    ret = subprocess.run(
        ['python2', 'tests/sls/homu/get_buildbot_cfg.py'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    if ret.returncode != 0:
        return Failure(
            'Unable to retrieve buildbot builders name:', ret.stderr
        )

    buildbot_builders = json.loads(ret.stdout.decode('utf-8'))['builders']

    if not is_builders_valid(buildbot_builders, homu_buildbot['builders']):
        return Failure(
            'Homu config is not in sync with the buildbot config', ''
        )
    if not is_builders_valid(buildbot_builders, homu_buildbot['try_builders']):
        return Failure(
            'Homu config is not in sync with the buildbot config', ''
        )

    return Success('Buildbot and homu configs are synced.')
