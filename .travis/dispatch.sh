#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

shopt -s nullglob

salt_call() {
    ${SUDO} salt-call \
        --force-color \
        --id="${SALT_NODE_ID}" \
        --local --file-root='./.' --pillar-root='./.travis/test_pillars' \
        "$@"
}

travis_fold_start() {
    printf "travis_fold:start:%s\n" "${1}"
    printf "%s\n" "${2}"
}

travis_fold_end() {
    printf "travis_fold:end:%s\n" "${1}"
}

install_salt() {
    travis_fold_start "salt.install.$1" 'Installing and configuring Salt'
    .travis/install_salt.sh -F -c .travis -- "${TRAVIS_OS_NAME}"
    travis_fold_end "salt.install.$1"
}

run_salt() {
    install_salt "${1}"

    travis_fold_start "grains.items.$1" 'Printing Salt grains for debugging'
    salt_call grains.items
    travis_fold_end "grains.items.$1"

    travis_fold_start "state.show_highstate.$1" \
        'Performing basic YAML and Jinja validation'
    salt_call --retcode-passthrough state.show_highstate
    travis_fold_end "state.show_highstate.$1"

    printf 'Running the full Salt highstate\n'
    salt_call --retcode-passthrough --log-level=warning state.highstate
}


run_inside_docker() {
    # Reexec this script inside docker
    # (without exporting the `SALT_DOCKER_IMAGE` environment variable
    # to prevent recursion)
    local -r DOCKER_SALT_ROOT="/tmp/salt"
    docker run \
        --env="SALT_NODE_ID=${SALT_NODE_ID}" \
        --env="SALT_FROM_SCRATCH=${SALT_FROM_SCRATCH}" \
        --env="TRAVIS_COMMIT=${TRAVIS_COMMIT}" \
        --env="TRAVIS_OS_NAME=${TRAVIS_OS_NAME}" \
        --volume="$(pwd):${DOCKER_SALT_ROOT}" \
        --workdir="${DOCKER_SALT_ROOT}" \
        "${SALT_DOCKER_IMAGE}" \
        "${DOCKER_SALT_ROOT}/.travis/dispatch.sh"
}


setup_test_venv() {
    if ! which salt-call >/dev/null; then
        install_salt 'test_venv'
    fi
    travis_fold_start 'test_venv.install_python3' \
        'Setting up Python 3 virtualenv for testing'
    # Use the system Python 3 to make it easy to run tests on fresh hosts
    # Make sure dependencies are installed (like `python3-venv` on Debian derivatives)
    salt_call --retcode-passthrough state.sls python
    travis_fold_end 'test_venv.install_python3'


    printf "Using %s at %s\n" "$(python3 --version)" "$(which python3)"

    travis_fold_start 'test_venv.install_requirements' \
        'Installing pip dependencies for testing'
    local -r VENV_DIR="/tmp/saltfs-venv3"
    python3 -m venv "${VENV_DIR}"
    set +o nounset
    source "${VENV_DIR}/bin/activate"
    set -o nounset
    pip install wheel
    pip install -r requirements.txt
    travis_fold_end 'test_venv.install_requirements'
}


SUDO=""
if (( EUID != 0 )); then
    SUDO="sudo"
fi

# Accommodate homebrew changes to python 2/3 formulas.
if [[ "${SALT_NODE_ID}" =~ servo-mac.* ]]; then
    brew update
    brew upgrade python
fi

if [[ "${SALT_NODE_ID}" == "test" ]]; then
    # Run test suite separately for parallelism
    setup_test_venv
    ./test.py
elif [[ -n "${SALT_DOCKER_IMAGE:-}" ]]; then  # macOS bash is too old for `-v`
    printf "Using %s\n" "$(docker -v)"

    run_inside_docker "$@"
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

        git checkout "${TRAVIS_COMMIT}"

        travis_fold_start "salt.invalidate_cache" 'Invalidating the Salt cache'
        salt_call 'saltutil.clear_cache'
        salt_call 'saltutil.sync_all'
        travis_fold_end "salt.invalidate_cache"

        run_salt 'upgrade'
    fi

    # Only run tests against the new configuration
    setup_test_venv

    # TODO: don't hard-code this
    if [[ "${SALT_NODE_ID}" == "servo-master1" ]]; then
        ./test.py sls.buildbot.master sls.homu sls.nginx
    fi
    if [[ "${SALT_NODE_ID}" == "servo-linux-cross1" ]]; then
        ./test.py sls.servo-build-dependencies.android
    fi

    # Salt doesn't support timezone.system on OSX
    # See https://github.com/saltstack/salt/issues/31345
    if [[ ! "${SALT_NODE_ID}" =~ servo-mac.* ]]; then
        ./test.py sls.common
    fi
fi
