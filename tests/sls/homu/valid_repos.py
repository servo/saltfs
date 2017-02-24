import os
import toml
import requests
from tests.util import Failure, Success


def repo_pager(endpoint, repoblock, auth):
    """
    recursively consumes an endpoint and an empty (self-populating) list
    it will exit when it fails to find the 'next' key in the links dict
    """
    req = requests.get(endpoint, headers=auth)
    repoblock += req.json()
    try:
        next_req_endpoint = req.links['next']['url']
        repo_pager(next_req_endpoint, repoblock, auth)
    except KeyError:
        return repoblock


def run():
    # these try and except blocks are largely to compensate for potential
    # upstream problems with requests and toml

    # list of repos in homu build configuration
    try:
        configured_repos = toml.load('/home/servo/homu/cfg.toml')['repo']
        keys = configured_repos.keys()
        # in the event that libraries outside servo org
        homu_repos = ["https://github.com/"+configured_repos[i]['owner']+'/'+i
                      for i in keys]
    except Exception as e:
        return Failure('Unable to construct list of homu repos', str(e))
    try:
        auth = {'Authorization': 'token '+os.environ['TOKEN']}
        x = []
        repo_pager('https://api.github.com/orgs/servo/repos', x, auth)
        # grok out the html_url's
        gh_repos = [block['html_url'] for block in x]
    except Exception as e:
        return Failure('Unable to construct list of github repos:', str(e))

    # set difference from homu to github
    homu_repo_diff = list(set(homu_repos) - set(gh_repos))

    # merging homu repos not on github
    homu_err_msg = ' '.join(homu_repo_diff)
    if len(homu_repo_diff) > 0:
        return Failure('repos in homu not on github: ',
                       homu_err_msg)
    elif len(homu_repo_diff) == 0:
        return Success('Clean between github and homu repos')
