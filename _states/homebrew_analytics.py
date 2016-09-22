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
        'The homebrew_analytics state mod could not be loaded: brew not found'
    )


def _check_analytics_status():
    out = __salt__['homebrew.cmd_all'](['analytics', 'state'])['stdout']
    if len(out) < 1:
        raise CommandExecutionError('Failed to parse brew analytics state')
    status_line = out.splitlines()[0]
    if 'enabled' in status_line:
        return True
    elif 'disabled' in status_line:
            return False
    raise CommandExecutionError('Failed to parse brew analytics state')


def managed(name, **kwargs):
    '''
    Manage Homebrew analytics state (either enabled or disabled).

    name
        Either 'enabled' or 'disabled'
    '''
    ret = {
        'name': name,
        'changes': {},
        'result': None,
        'comment': '',
    }

    # Var must be called 'name' due to design of Salt
    wanted = None
    if name == 'enabled':
        wanted = True
    elif name == 'disabled':
        wanted = False
    else:
        ret['result'] = False
        ret['comment'] = '`name` parameter must be `enabled` or `disabled`'
        return ret
    wanted_v = name[:-1]  # Verb form

    try:
        current = _check_analytics_status()
        if current == wanted:
            ret['result'] = True
            ret['comment'] = 'Homebrew analytics are already {}'.format(name)
            return ret

        if __opts__['test']:
            ret['comment'] = 'Homebrew analytics need to be {}'.format(name)
            return ret

        state_arg = 'on' if wanted else 'off'
        # Exception bubbles, so we can ignore the return value
        __salt__['homebrew.cmd_all'](['analytics', state_arg])

        new = _check_analytics_status()
        if new == wanted:
            ret['changes']['homebrew_analytics'] = {
                'old': 'enabled' if current else 'disabled',
                'new': name,
            }
            ret['result'] = True
            ret['comment'] = 'Homebrew analytics was {}'.format(name)
            return ret
        else:
            ret['result'] = False
            ret['comment'] = 'Failed to {} Homebrew analytics'.format(wanted_v)
            return ret

    except CommandExecutionError as err:
        ret['result'] = False
        ret['comment'] = 'Failed to {} Homebrew analytics: {}'.format(
            wanted_v,
            err
        )
        return ret
