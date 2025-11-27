# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.2@sha256:1010757416068f5a14c04bbe478846c271353353472435105ff56b57190c9225 AS build
RUN --mount=type=bind,from=designate,source=/,target=/src/designate,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/designate
EOF

FROM ghcr.io/vexxhost/python-base:2024.2@sha256:ee93b4b616878eabea5775e94257c88c808656307fa85f92e14b9f3e48d49e66
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
