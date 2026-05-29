# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.1@sha256:0a56a1e5f7e50e9e14e2736ef6f81d09efb66ad41f4315327b8503c028ac1164 AS build
RUN --mount=type=bind,from=designate,source=/,target=/src/designate,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/designate
EOF

FROM ghcr.io/vexxhost/python-base:2024.1@sha256:4548144ca5b237f676c61b501dcd805f9675ae3e24ea5902dbb7cd4c976ed545
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
