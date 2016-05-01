#!/usr/bin/env sh

set -o errexit
set -o nounset

salt_call() {
    sudo salt-call \
        --id="${SALT_NODE_ID}" \
        --local --file-root=. --pillar-root=./.travis/test_pillars \
        "$@"
}

if [ "${SALT_NODE_ID}" = "test" ]; then
    # Using .travis.yml to specify Python 3.5 to be preinstalled, just to check
    printf "Using $(python3 --version) at $(which python3)\n"

    # Run test suite separately for parallelism
    ./test.py
else
    .travis/install_salt.sh -F -c .travis -- "${TRAVIS_OS_NAME}"

    # For debugging, check the grains reported by the Travis builder
    salt_call grains.items

    # Minimally validate YAML and Jinja at a basic level
    salt_call --retcode-passthrough state.show_highstate

    # Full on installation test
    salt_call --retcode-passthrough --log-level=warning state.highstate

    # TODO: don't hard-code this
    if [ "${SALT_NODE_ID}" = "servo-master1" ]; then
        ./test.py sls.buildbot.master sls.nginx
    fi
fi
