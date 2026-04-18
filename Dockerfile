# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.2@sha256:0b6e64e4a2601e641ded1f1e03d955d476db6675cc80ab83b8d22d9f4869f113 AS build
RUN --mount=type=bind,from=designate,source=/,target=/src/designate,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/designate
EOF

FROM ghcr.io/vexxhost/python-base:2024.2@sha256:30ea7e408815efcc29df2764703d3b6256c2b7ee0f31b1e290cb34ddf6f44694
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
