import toml
import urllib.request
from urllib.error import URLError
from tests.util import Failure, Success


def getStatus(url):
    '''
    Consumes a url string and returns the status code of a GET request
    '''
    try:
        response = urllib.request.urlopen(url).status
    except URLError:
        response = url
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
                        if getStatus(VCS+repository) != 200]
    failed_resp_str = " \n".join(failed_responses)
    if len(failed_responses) > 0:
        return Failure('repos in homu not on github: ',
                       failed_resp_str)
    else:
        return Success('All repos in homu config on github')
