import toml

from tests.util import Failure, Success


def run():
    try:
        toml.load('/home/servo/homu/cfg.toml')
    except Exception as e:
        return Failure('Homu config file is not valid TOML:', str(e))
    return Success('Homu config file is valid TOML')
