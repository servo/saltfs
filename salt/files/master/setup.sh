#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

exec git clone https://github.com/servo/saltfs.git
