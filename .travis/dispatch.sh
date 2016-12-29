#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

shopt -s nullglob

salt_call() {
    sudo salt-call \
        --id="${SALT_NODE_ID}" \
        --local --file-root='./.' --pillar-root='./.travis/test_pillars' \
        "$@"
}

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
    travis_fold_end "salt.install.$1"

    travis_fold_start "grains.items.$1" 'Printing Salt grains for debugging'
    salt_call grains.items
    travis_fold_end "grains.items.$1"

    travis_fold_start "state.show_highstate.$1" 'Performing basic YAML and Jinja validation'
    salt_call --retcode-passthrough state.show_highstate
    travis_fold_end "state.show_highstate.$1"

    printf 'Running the full Salt highstate\n'
    salt_call --retcode-passthrough --log-level=warning state.highstate
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
        # Upstream changes could cause the old rev to fail, so disable errexit
        # (homu will maintain the invariant that each rev on master is passing)
        set +o errexit
        run_salt 'old'
        set -o errexit

        travis_fold_start "salt.invalidate_cache" 'Invalidating the Salt cache'
        rm -rf /var/cache/salt/minion/files/base/*
        salt_call 'saltutil.sync_all'
        travis_fold_end "salt.invalidate_cache"

        git checkout "${TRAVIS_COMMIT}"
        run_salt 'upgrade'
    fi

    # Only run tests against the new configuration
    # TODO: don't hard-code this
    if [[ "${SALT_NODE_ID}" == "servo-master1" ]]; then
        ./test.py sls.buildbot.master sls.common.timezone sls.homu sls.nginx
    fi
fi
