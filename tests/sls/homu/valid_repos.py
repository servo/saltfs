from urllib.error import URLError
from urllib.request import Request, urlopen

import toml

from tests.util import Failure, Success


def repoExists(identifier):
    '''
    Consumes a repo identifier string in the form of owner/name and returns a
    boolean indicating whether the request to check if the repository exists
    on github was successful (200) or not
    '''
    try:
        endpoint = "https://github.com/{}".format(identifier)
        requester = Request(endpoint, method='HEAD')
        with urlopen(requester) as conn:
            if conn.status != 200:
                response = False
            else:
                response = True
    except URLError:
        response = False
    return response


def run():
    repo_cfg = toml.load('/home/servo/homu/cfg.toml')['repo']
    # formatting to more easily form a url to submit a request to
    homu_repos = ("{}/{}".format(repo['owner'], repo['name'])
                  for repo in repo_cfg.values())
    missing_repos = ["- {}".format(repository) for repository in homu_repos
                     if not repoExists(repository)]
    if len(missing_repos) > 0:
        return Failure('repos in homu not on github: ',
                       "\n".join(missing_repos))
    else:
        return Success('All repos in homu config on github')
