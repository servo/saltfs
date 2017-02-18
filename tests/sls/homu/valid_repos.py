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

        # set difference from github to homu
        gh_repo_diff = list(set(gh_repos) - set(homu_repos))
        # set difference from homu to github
        homu_repo_diff = list(set(homu_repos) - set(gh_repos))

        # merging github repos not on homu
        gh_err_msg = ' https://github.com/servo/'.join(gh_repo_diff)
        # merging homu repos not on github
        homu_err_msg = ' '.join(homu_repo_diff)
        
        dual_inconsistency = 'Inconsistency between both homu and github repos:'
        dual_msg = '\t on github: '+gh_err_msg+ '\n \t on homu: ' +homu_err_msg
        # if both repos are out of sync, show inconsistencies
        if len(gh_repo_diff) > 0 and len(homu_repo_diff) > 0:
            return Failure(dual_inconsistency, dual_msg)
#        if github is out of sync, show inconsistency
        if len(gh_repo_diff) > 0:
            return Failure('repos on github not in homu: ',
                           gh_err_msg)
        # if homu is out of sync, show inconsistency
        elif len(homu_repo_diff) > 0:
            return Failure('repos in homu not on github: ',
                           homu_err_msg)
        elif len(homu_repo_diff) == 0 and len(gh_repo_diff) == 0:
            return Success('Clean between github and homu repos')
