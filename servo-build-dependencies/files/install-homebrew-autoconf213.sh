#!/usr/bin/env bash

# Homebrew insists on being stateful, non-idempotent, lacking useful command
# line flags, and in general hard to administer, so this is a custom script for
# the simple yet impossible via Homebrew CLI task of installing two versions of
# the same package, without an error.
# Specifically, autoconf213 and autoconf need to be installed, with autoconf's
# links taking precedence.

set -o errexit
set -o nounset
set -o pipefail


# Helper methods because brew doesn't like conflicting links during install,
# and there is no way to install w/o linking from the CLI or ignore that error,
# only via editing the Formula to add `keg_only`.
# Hence, just ignore errors for now, and double-check everything at the end.
brew_install() { set +o errexit; brew install "$@"; set -o errexit; }
brew_link() { set +o errexit; brew link "$@"; set -o errexit; }

# Use "yes"/"no" for conditionals (not "true"/"false")
# to avoid confusion with the true/false commands
autoconf_installed="no"
autoconf_fully_linked="no"
autoconf213_installed="no"
autoconf213_linked="no"


set_autoconf_vars() {
    if brew list | grep 'autoconf' >/dev/null; then
        autoconf_installed="yes"
        if readlink '/usr/local/share/info/autoconf.info' \
                | grep 'Cellar/autoconf/' >/dev/null; then
            autoconf_fully_linked="yes"
        fi
    fi
}


set_autoconf213_vars() {
    if brew list | grep 'autoconf213' >/dev/null; then
        autoconf213_installed="yes"
        if readlink '/usr/local/bin/autoconf213' \
                | grep 'Cellar/autoconf213/' >/dev/null; then
            autoconf213_linked="yes"
        fi
    fi
}


check() {
    local verbose="no"
    if [[ "$#" -ge 1  && "${1}" == 'verbose' ]]; then
        declare -r verbose="yes"
    fi
    set_autoconf_vars
    set_autoconf213_vars

    if [[     "${autoconf213_installed}" == "yes"
           && "${autoconf_installed}" == "yes"
           && "${autoconf213_linked}" == "yes"
           && "${autoconf_fully_linked}" == "yes" ]]; then
        return 0
    else
        if [[ "${verbose}" == "yes" ]]; then
            printf "%s\n" "autoconf/autoconf213 check failed:"
            printf "%s %s\n" "autoconf 213 installed?" \
                "${autoconf213_installed}"
            printf "%s %s\n" "autoconf installed?" \
                "${autoconf_installed}"
            printf "%s %s\n" "autoconf213 linked?" \
                "${autoconf213_linked}"
            printf "%s %s\n" "autoconf fully linked?" \
                "${autoconf_fully_linked}"
        fi

        return 1
    fi
}


main() {
    if check; then
        return 0
    fi

    # autoconf213 is first so autoconf can override
    set_autoconf213_vars
    if [[ "${autoconf213_installed}" == "no" ]]; then
        brew_install autoconf213
    fi
    set_autoconf213_vars
    if [[ "${autoconf213_linked}" == "no" ]]; then
        brew_link --overwrite autoconf213
    fi

    set_autoconf_vars
    if [[ "${autoconf_installed}" == "no" ]]; then
        brew_install autoconf
    fi
    set_autoconf_vars
    if [[ "${autoconf_fully_linked}" == "no" ]]; then
        brew_link --overwrite autoconf
    fi

    check 'verbose' # errexit will handle return in failure case
    return 0
}


main "$@"
