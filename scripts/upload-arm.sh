#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


usage () {
    printf "usage: $0 <path_to_rootfs_tarball> <arch> <version>\n"
    printf "\n"
    printf "example: $0 ./armhf-trusty-libs.tgz armhf v3\n"
}


upload () {
    local -r local_filename="$1"
    local -r arch="$2"
    local -r version="$3"

    local -r remote_location="s3://servo-rust/ARM/${arch}-trusty-libs/${version}/${arch}-trusty-libs-${version}.tgz"
    printf "Uploading ${local_filename} to ${remote_location}. Proceed? [Y/n]"
    local proceed
    read proceed
    if [[ "${proceed}" == "N" || "${proceed}" == "n" ]]; then
        printf "Upload aborted.\n"
        return 0
    fi
    s3cmd put "${local_filename}" "${remote_location}"
}

main () {
    if [[ "$#" != 3 ]]; then
        usage >&2
        exit 1
    fi
    if [[ ! -e "$1" ]]; then
        printf >&2 "$0: $1 does not exist for uploading\n"
        exit 1
    fi
    if [[ "$2" != "armhf" && "$2" != "arm64" ]]; then
        printf >&2 "$0: unknown arch $2, please specify either armhf or arm64\n"
        exit 1
    fi
    if [[ "$3" != v* ]]; then
        printf >&2 "$0: version $3 must start with a v\n"
        exit 1
    fi

    upload "$@"
}

main "$@"
