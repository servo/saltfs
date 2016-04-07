#!/usr/bin/env sh

set -o errexit
set -o nounset

if [ "${SALT_NODE_ID}" = "test" ]; then
    # Using .travis.yml to specify Python 3.5 to be preinstalled, just to check
    printf "Using $(python3 --version) at $(which python3)\n"

    # Run test suite separately for parallelism
    ./test.py
else
    .travis/install_salt.sh -F -c .travis -- "${TRAVIS_OS_NAME}"
    .travis/setup_salt_roots.sh

    # For debugging, check the grains reported by the Travis builder
    sudo salt-call --id="${SALT_NODE_ID}" grains.items

    # Minimally validate YAML and Jinja at a basic level
    sudo salt-call --id="${SALT_NODE_ID}" --retcode-passthrough state.show_highstate
    # Full on installation test
    sudo salt-call --id="${SALT_NODE_ID}" --retcode-passthrough --log-level=warning state.highstate

    # TODO: don't hard-code this
    if [ "${SALT_NODE_ID}" = "servo-master1" ]; then
        ./test.py sls.buildbot.master
    fi
fi
