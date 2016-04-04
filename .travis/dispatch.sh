#!/usr/bin/env sh

set -o errexit
set -o nounset

if [ "${SALT_NODE_ID}" = "test" ]; then
    # Should already be installed, but just in case
    which python3 || sudo apt-get -y install python3

    # Run test suite separately for parallelism
    ./test.py
else
    .travis/install-salt -F -c .travis -- "${TRAVIS_OS_NAME}"
    .travis/setup_salt_roots

    # For debugging, check the grains reported by the Travis builder
    sudo salt-call --id="${SALT_NODE_ID}" grains.items

    # Minimally validate YAML and Jinja at a basic level
    sudo salt-call --id="${SALT_NODE_ID}" --retcode-passthrough state.show_highstate
    # Full on installation test
    sudo salt-call --id="${SALT_NODE_ID}" --retcode-passthrough --log-level=warning state.highstate
fi
