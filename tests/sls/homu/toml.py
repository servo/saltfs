import os

import toml

from tests.util import Failure, Success, project_path


def run():
    config_path = os.path.join('/home', 'servo', 'homu', 'cfg.toml')
    with open(config_path) as conf:
        try:
            toml.loads(conf.read())
            return Success('Homu config file is valid TOML')
        except Exception as e:
            return Failure('Homu config file is not valid TOML: ', '{}'.format(e))
