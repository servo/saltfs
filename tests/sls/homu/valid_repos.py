import toml
import requests
from tests.util import Failure, Success


def repo_pager(endpoint, repoblock, auth):
    """
    recursively consumes an endpoint and an empty (self-populating) list
    it will exit when it fails to find the 'next' key in the links dict
    """
    req = requests.get(endpoint, headers=auth)
    # the requests lib will raise an HTTPError exception for weird responses
    req.raise_for_status()
    repoblock += req.json()
    try:
        next_req_endpoint = req.links['next']['url']
        repo_pager(next_req_endpoint, repoblock, auth)
    except KeyError:
        return repoblock


def run():
    # these try and except blocks are largely to compensate for potential
    # upstream problems with requests and toml

    try:
        homu_cfg = toml.load('/home/servo/homu/cfg.toml')
    except Exception as e:
        return Failure('Unable to read the homu cfg.toml', str(e))
    # list of repos in homu build configuration
    try:
        configured_repos = homu_cfg['repo']
        keys = configured_repos.keys()
        # in the event that libraries outside servo org
        homu_repos = ["https://github.com/"+configured_repos[i]['owner']+'/'+i
                      for i in keys]
    except Exception as e:
        return Failure('Unable to construct list of homu repos', str(e))
    try:
        access_token = homu_cfg['github']['access_token']
        auth = {'Authorization': 'token '+access_token}
        req_list = []
        repo_pager('https://api.github.com/orgs/servo/repos', req_list, auth)
        # grok out the html_url's
        # when the github api fails to authenticate, the html_url key will not
        # exist in the req dicts
        gh_repos = [req['html_url'] for req in req_list]
    except TypeError as e:
        return Failure('Unable to authorize to github API', str(e))
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
