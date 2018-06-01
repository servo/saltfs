#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${USER}" == "vagrant" ]]; then
    echo 'Inside Vagrant, the Salt override directory is actually a mount.'
    echo 'Refusing to delete your local checkout.'
    exit 1
fi

exec rm -r saltfs/
