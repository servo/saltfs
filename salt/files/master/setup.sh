#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


main() {
    if (( $# != 1)); then
        printf 'usage: %s <github_handle>\n' "${0}"
        return 1
    fi

    git clone https://github.com/servo/saltfs.git
    echo "${1} @ $(date --utc --iso-8601=seconds)" > saltfs/CLONER
}


main "$@"
