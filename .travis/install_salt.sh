#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

install_salt () {
    # Ensure that pinned versions match as closely as possible
    if [[ "${OS_NAME}" == "linux" ]]; then
        printf "$0: installing salt for Linux\n"
        # Use Trusty (Ubuntu 14.04) on Travis
        # Don't autostart services
        printf '#!/bin/sh\nexit 101\n' | sudo install -m 755 /dev/stdin /usr/sbin/policy-rc.d
        curl https://repo.saltstack.com/apt/ubuntu/14.04/amd64/archive/2016.3.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
        printf 'deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/archive/2016.3.3 trusty main\n' | sudo tee /etc/apt/sources.list.d/saltstack.list >/dev/null
        sudo apt-get -y update
        # Use existing config file if it exists (if reinstalling)
        sudo apt-get -y \
                -o Dpkg::Options::="--force-confold" \
                -o Dpkg::Options::="--force-confdef" \
                install salt-minion=2016.3.3+ds-1
    elif [[ "${OS_NAME}" == "osx" ]]; then
        printf "$0: installing salt for Mac OS X\n"
        brew update
        # Unlink allows switching versions,
        # I wish Homebrew had an atomic operation for pinned upgrades
        if brew list | grep 'saltstack' >/dev/null; then
            brew unlink saltstack
        fi
        brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/9e3a66b6b7ca978bfea86897dcc3391c37f9f0ef/Formula/saltstack.rb
        # In case we had the same version previously, we need to relink
        brew link saltstack
    else
        printf >&2 "$0: unknown operating system ${OS_NAME}\n"
        exit 1
    fi
}

configure_salt () {
    printf "$0: copying Salt minion configuration from ${TEMPORARY_CONFIG_DIR}\n"
    sudo rm -rf /etc/salt
    sudo mkdir -p /etc/salt
    sudo cp "${FORCE_FLAG}" -- "${TEMPORARY_CONFIG_DIR}/minion" /etc/salt/minion
}

OPTIONS=$(getopt 'c:CF' "$@")

eval set -- "${OPTIONS}"

TEMPORARY_CONFIG_DIR=""
CONFIGURE_ONLY=""
FORCE_FLAG=""
OS_NAME=""

while true; do
    case "$1" in
        -c)
            shift
            TEMPORARY_CONFIG_DIR="$1"
            shift
            ;;
        -C)
            CONFIGURE_ONLY="true"
            FORCE_FLAG="-f" # -C implies -F
            shift
            ;;
        -F)
            FORCE_FLAG="-f"
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [[ "$#" -lt 1 ]]; then
    printf >&2 "usage: $0 [-c <config_dir> [-F]] [--] os_name\n"
    exit 1
fi

OS_NAME="$1"
if [[ -z "${CONFIGURE_ONLY}" ]]; then
    install_salt
fi

if [[ -n "${TEMPORARY_CONFIG_DIR}" ]]; then
    configure_salt
fi
