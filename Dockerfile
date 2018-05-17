# ubuntu:trusty
# NOTE: Keep in sync with .travis.yml
FROM ubuntu@sha256:084989eb923bd86dbf7e706d464cf3587274a826b484f75b69468c19f8ae354c

ARG SALT_ROOT=/tmp/salt-bootstrap
ARG SALT_NODE_ID=servo-linux1

COPY ./ "${SALT_ROOT}"

RUN : \
 && apt-get update \
 && apt-get -y install --no-install-recommends \
         ca-certificates \
         curl \
 && "${SALT_ROOT}/.travis/install_salt.sh" linux \
 && salt-call \
        --local \
        --id="${SALT_NODE_ID}" \
        --config-dir="${SALT_ROOT}/.travis" \
        --file-root="${SALT_ROOT}" \
        --retcode-passthrough \
        --force-color \
        state.apply common,servo-build-dependencies \
        pillar='{"fully_managed": False}' \
 && rm -rf "${SALT_ROOT}" \
 && rm -rf "/var/cache/salt" \
 && apt-get purge -y salt-minion \
 && apt-get autoremove --purge -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && :

USER servo
ENV SHELL=/bin/bash
WORKDIR /home/servo
