from urllib.error import URLError
from urllib.request import Request, urlopen

import toml

from tests.util import Failure, Success


def repo_exists(url):
    '''
    Checks if the given repo exists on GitHub
    '''
    try:
        request = Request("https://github.com/{}".format(url), method='HEAD')
        with urlopen(request) as conn:
            return conn.status == 200
    except URLError:
        return False


def run():
    repo_cfg = toml.load('/home/servo/homu/cfg.toml')['repo']
    homu_repos = (
        "{}/{}".format(repo['owner'], repo['name'])
        for repo in repo_cfg.values()
    )
    missing_repos = [
        repository for repository in homu_repos
        if not repo_exists(repository)
    ]
    if len(missing_repos) > 0:
        return Failure(
            'Some repos set up for Homu do not exist on GitHub:',
            "\n".join(" - {}".format(repo) for repo in missing_repos)
        )
    return Success('All repos in the Homu config exist on Github')
