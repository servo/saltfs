from urllib.error import URLError
import urllib.request

import toml

from tests.util import Failure, Success


def repoExists(identifier):
    '''
    Consumes a repo identifier string in the form of owner/name and returns a
    boolean indicating whether the request to check if the repository exists
    on github was successful (200) or not
    '''
    try:
        if urllib.request.urlopen(identifier).status != 200:
            response = False
        else:
            response = True
    except URLError:
        response = False
    return response


def run():
    # repository configuration dictionary from homu
    repo_cfg = toml.load('/home/servo/homu/cfg.toml')['repo']
    VCS = "https://github.com/"
    # extracting owner and repo from the configuration dict
    # and formatting it to more easily form a url to submit a request to
    homu_repos = [repo_cfg[repo_title]['owner']+'/'+repo_title
                  for repo_title in repo_cfg.keys()]
    failed_responses = [repository for repository in homu_repos
                        if not repoExists(VCS+repository)]
    failed_resp_str = " \n".join(failed_responses)
    if len(failed_responses) > 0:
        return Failure('repos in homu not on github: ',
                       failed_resp_str)
    else:
        return Success('All repos in homu config on github')
