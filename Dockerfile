# ubuntu:xenial
# NOTE: Keep in sync with .travis.yml
FROM ubuntu@sha256:f3a61450ae43896c4332bda5e78b453f4a93179045f20c8181043b26b5e79028

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
