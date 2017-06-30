# Ubuntu Xenial
FROM ubuntu@sha256:a0ee7647e24c8494f1cf6b94f1a3cd127f423268293c25d924fbe18fd82db5a4

ARG SALT_ROOT=/tmp/salt-bootstrap

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
        --log-level=warning \
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
