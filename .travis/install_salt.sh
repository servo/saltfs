#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

install_salt() {
    # Ensure that pinned versions match as closely as possible
    if [[ "${OS_NAME}" == "linux" ]]; then
        local os_codename os_release
        os_codename="$(grep 'DISTRIB_CODENAME' /etc/lsb-release | cut -f2 -d'=')"
        declare -r os_codename
        os_release="$(grep 'DISTRIB_RELEASE' /etc/lsb-release | cut -f2 -d'=')"
        declare -r os_release
        printf \
            "%s: installing salt for Linux (%s, %s)\n" \
            "${0}" "${os_codename}" "${os_release}"

        # Don't autostart services
        printf '#!/bin/sh\nexit 101\n' | \
            ${SUDO} install -m 755 /dev/stdin /usr/sbin/policy-rc.d

        # Ensure curl is installed (is not present by default in Docker)
        ${SUDO} apt-get -y update
        ${SUDO} apt-get -y install --no-install-recommends ca-certificates curl apt-transport-https

        curl "https://repo.saltstack.com/apt/ubuntu/${os_release}/amd64/archive/2016.3.3/SALTSTACK-GPG-KEY.pub" | \
            ${SUDO} apt-key add -
        printf \
            'deb http://repo.saltstack.com/apt/ubuntu/%s/amd64/archive/2016.3.3 %s main\n' \
            "${os_release}" "${os_codename}" | \
                ${SUDO} tee /etc/apt/sources.list.d/saltstack.list >/dev/null
        ${SUDO} apt-get -y update
        # Use existing config file if it exists (if reinstalling)
        ${SUDO} apt-get -y \
                -o Dpkg::Options::="--force-confold" \
                -o Dpkg::Options::="--force-confdef" \
                install salt-minion=2016.3.3+ds-1
    elif [[ "${OS_NAME}" == "osx" ]]; then
        printf "%s: installing salt for Mac OS X\n" "${0}"
        brew update
        printf "\nhomebrew --version output:\n"
        brew --version # For debugging
        printf "\n"
        # Unlink allows switching versions,
        # I wish Homebrew had an atomic operation for pinned upgrades
        if brew list | grep 'saltstack' >/dev/null; then
            brew unlink saltstack
        fi
        # Was: https://raw.githubusercontent.com/Homebrew/homebrew-core/9e3a66b6b7ca978bfea86897dcc3391c37f9f0ef/Formula/saltstack.rb
        # We use our own copy of that old formula. We replaced EOS.undent with EOS to be compatible with the latest homebrew version
        brew install --build-from-source .travis/saltstack.rb
        # In case we had the same version previously, we need to relink
        brew link saltstack
    else
        printf >&2 "%s: unknown operating system %s\n" "${0}" "${OS_NAME}"
        exit 1
    fi
}

configure_salt() {
    printf \
        "%s: copying Salt minion configuration from %s\n" \
        "${0}" "${TEMPORARY_CONFIG_DIR}"
    ${SUDO} rm -rf /etc/salt
    ${SUDO} mkdir -p /etc/salt
    ${SUDO} cp "${FORCE_FLAG}" -- \
        "${TEMPORARY_CONFIG_DIR}/minion" /etc/salt/minion
}

SUDO=""
if (( EUID != 0 )); then
    SUDO="sudo"
fi

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
    printf >&2 "usage: %s [-c <config_dir> [-F]] [--] os_name\n" "${0}"
    exit 1
fi

OS_NAME="$1"
if [[ -z "${CONFIGURE_ONLY}" ]]; then
    install_salt
fi

if [[ -n "${TEMPORARY_CONFIG_DIR}" ]]; then
    configure_salt
fi
