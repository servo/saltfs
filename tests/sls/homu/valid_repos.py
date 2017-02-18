import toml
import requests
from tests.util import Failure, Success


def run():
    # these try and except blocks are largely to compensate for potential
    # upstream problems with requests and toml
    try:
        gh_repos = [repo['name'] for repo in requests.get(
            'https://api.github.com/orgs/servo/repos').json()]
    except Exception as e:
        return Failure('Unable to construct list of github repos:', str(e))
    # list of repos in homu build configuration
    try:
        homu_repos = toml.load('/home/servo/homu/cfg.toml')['repo'].keys()
    except Exception as e:
        return Failure('Unable to construct list of homu repos', str(e))

    # set difference from homu to github
    homu_repo_diff = list(set(homu_repos) - set(gh_repos))
    
    # merging homu repos not on github
    homu_err_msg = ' '.join(homu_repo_diff)
    
    if len(homu_repo_diff) > 0:
        return Failure('repos in homu not on github: ',
                           homu_err_msg)
    elif len(homu_repo_diff) == 0:
        return Success('Clean between github and homu repos')
