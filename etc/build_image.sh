#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

shopt -s nullglob


main() {
    docker build \
        --force-rm=true \
        --no-cache=true \
        --compress=true \
        ./.
}


main "$@"
