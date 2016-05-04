#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

setup_salt_roots () {
    sudo rm -rf /srv/salt
    sudo mkdir -p /srv/salt
    sudo cp -r . /srv/salt/states
    sudo cp -r .travis/test_pillars /srv/salt/pillars
}

setup_salt_roots "$@"
