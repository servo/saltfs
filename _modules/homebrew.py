# This module is mainly comprised of new code, but also contains modified
# versions of functions from the salt/modules/mac_brew.py module from Salt
# develop (at git revision 3e5218daea73f3f24b82a3078764ccb82c2a1ec9).
# Functions taken/modified from Salt are marked, all others are original.
#
# The original copyright and licensing notice for the methods from the
# mac_brew.py module is reproduced below in the double-# comment block:
#
##   Salt - Remote execution system
##
##   Copyright 2014-2015 SaltStack Team
##
##   Licensed under the Apache License, Version 2.0 (the "License");
##   you may not use this file except in compliance with the License.
##   You may obtain a copy of the License at
##
##       http://www.apache.org/licenses/LICENSE-2.0
##
##   Unless required by applicable law or agreed to in writing, software
##   distributed under the License is distributed on an "AS IS" BASIS,
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##   See the License for the specific language governing permissions and
##   limitations under the License.

'''
Module for the management of homebrew
'''
from __future__ import absolute_import

# Import python libs
import logging
import os

# Import salt libs
from salt.exceptions import CommandExecutionError
import salt.utils

# Set up logging
log = logging.getLogger(__name__)


def __virtual__():
    '''
    Only work if Homebrew is installed
    '''
    if salt.utils.which('brew'):
        return True
    return (
        False,
        'The homebrew execution module could not be loaded: brew not found'
    )


def _homebrew_bin():
    '''
    Returns the full path to the homebrew binary in the PATH.
    Taken from mac_brew.py with modifications.
    '''
    homebrew_dir = __salt__['cmd.run'](
        'brew --prefix',
        output_loglevel='trace'
    )
    return os.path.join(homebrew_dir, 'bin', 'brew')


def cmd_all(args):
    '''
    Calls brew with the specified arguments and as the correct user.
    Taken from mac_brew.py with modifications.

    args:
        Should be a list of arguments to pass to the `brew` binary.
    '''
    user = __salt__['file.get_user'](_homebrew_bin())
    runas = user if user != __opts__['user'] else None
    ret = __salt__['cmd.run_all'](
        ['brew'] + args,
        runas=runas,
        output_loglevel='trace',
        python_shell=False,
        redirect_stderr=False,
    )
    if ret['retcode'] != 0:
        raise CommandExecutionError(
            'stdout: {stdout}\n'
            'stderr: {stderr}\n'
            'retcode: {retcode}\n'.format(**ret)
        )
    return ret
