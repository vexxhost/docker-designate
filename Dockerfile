# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2025.2@sha256:ea273f5373e75fe30a2258a31de4112f35df77072fba654e046f826b55647f07 AS build
RUN --mount=type=bind,from=designate,source=/,target=/src/designate,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/designate
EOF

FROM ghcr.io/vexxhost/python-base:2025.2@sha256:1f0d76f129e80217d774d482c1ff9147e78fd4db388bf350d1cbbd03b8c5c84d
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
