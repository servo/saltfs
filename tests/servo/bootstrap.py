import json

from tests.util import Failure, Success


def run():
    with open('.servo/salt/etc/salt/minion') as config_file:
        config = json.load(config_file)
        ok = config['fileserver_backend'] == ['roots']
        if ok:
            return Success("mach bootstrap ran with the local saltfs tree")
        else:
            return Failure("mach bootstrap created bad config:", config)
