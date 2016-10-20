import subprocess
import time
import os.path
from tempfile import TemporaryDirectory

from tests.util import Failure, Success

MINSCORE = '65'


def run():
    # set up
    with TemporaryDirectory() as http_obs:
        http_obs_dir = os.path.join(http_obs, 'http-observatory')
        # getting the observatory code
        subprocess.run(['git', 'clone', '--depth', '1',
                        'https://github.com/mozilla/http-observatory.git',
                        http_obs_dir], check=True)

        docker_compose = [
            'docker-compose', '-f',
            os.path.join(http_obs_dir, 'docker-compose.yml'),
            '-f', 'tests/sls/nginx/docker-compose-extra-observatory.yml']
        # getting the observatory up
        subprocess.run(docker_compose + ['up', '-d'], check=True)

        # sleep for 5 seconds, to increase the chance everything is really up
        print('sleep 5 seconds while composing up')
        time.sleep(5)

        # check our site to get the report nicely formatted in stdout
        subprocess.run(docker_compose +
                       ['run', 'observatory-cli', 'build.servo.org.test',
                        '--format', 'report', '--rescan',
                        '--attempts', '20'], check=True)

        # check our site a second time with a minimal score
        # to decide Fail / Pass
        report = subprocess.run(docker_compose + ['run', 'observatory-cli',
                                                  'build.servo.org.test',
                                                  '--min-score', MINSCORE],
                                stderr=subprocess.DEVNULL,
                                stdout=subprocess.DEVNULL)
        if report.returncode == 0:
            return Success('Http Observatory score more than %s' % MINSCORE)
        else:
            return Failure('Http Observatory score less than %s' % MINSCORE,
                           '')
