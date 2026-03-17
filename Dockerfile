# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:zed@sha256:2d0e23a84be9865b146a583e54e9c70ec417d9f7eee45f7f286dec312282758f AS build
RUN --mount=type=bind,from=designate,source=/,target=/src/designate,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/designate
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:aaebc3192ae08a1707356c70fa90e5d6127ada404318f7e85234a4b9e8084065
RUN \
    groupadd -g 42424 designate && \
    useradd -u 42424 -g 42424 -M -d /var/lib/designate -s /usr/sbin/nologin -c "Designate User" designate && \
    mkdir -p /etc/designate /var/log/designate /var/lib/designate /var/cache/designate && \
    chown -Rv designate:designate /etc/designate /var/log/designate /var/lib/designate /var/cache/designate
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    bind9utils
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=build --link /var/lib/openstack /var/lib/openstack
