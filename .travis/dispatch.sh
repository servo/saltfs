#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

travis_fold_start () {
    printf "travis_fold:start:$1\n"
    printf "$2\n"
}

travis_fold_end () {
    printf "travis_fold:end:$1\n"
}

run_salt () {
    travis_fold_start "salt.install.$1" 'Installing and configuring Salt'
    .travis/install_salt.sh -F -c .travis -- "${TRAVIS_OS_NAME}"
    .travis/setup_salt_roots.sh
    travis_fold_end "salt.install.$1"

    travis_fold_start "grains.items.$1" 'Printing Salt grains for debugging'
    sudo salt-call --id="${SALT_NODE_ID}" grains.items
    travis_fold_end "grains.items.$1"

    travis_fold_start "state.show_highstate.$1" 'Performing basic YAML and Jinja validation'
    sudo salt-call --id="${SALT_NODE_ID}" --retcode-passthrough state.show_highstate
    travis_fold_end "state.show_highstate.$1"

    printf 'Running the full Salt highstate\n'
    sudo salt-call --id="${SALT_NODE_ID}" --retcode-passthrough --log-level=warning state.highstate
}


if [[ "${SALT_NODE_ID}" == "test" ]]; then
    # Using .travis.yml to specify Python 3.5 to be preinstalled, just to check
    printf "Using $(python3 --version) at $(which python3)\n"

    # Run test suite separately for parallelism
    ./test.py
else
    if [ "${SALT_FROM_SCRATCH}" = "true" ]; then
        run_salt 'scratch'
    else
        git fetch origin master:master
        git checkout master
        run_salt 'old'

        git checkout "${TRAVIS_COMMIT}"
        run_salt 'upgrade'
    fi

    # Only run tests against the new configuration
    # TODO: don't hard-code this
    if [[ "${SALT_NODE_ID}" == "servo-master1" ]]; then
        ./test.py sls.buildbot.master sls.homu sls.nginx
    fi
fi
