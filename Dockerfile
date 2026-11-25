# lsd-cluster -- lsd-docker servers, each a container inside this one
#
# Copyright (C) 2026 Fran6nd. GPL-3.0-or-later; see LICENSE.
#
# A Docker engine of its own (Docker in Docker, so it runs --privileged)
# holding the instances, their volumes and the shared one; `lsdc`
# administers them. Everything it keeps is under /var/lib/docker: one
# volume is the whole cluster.
FROM docker:27.5.1-dind

# The engine's socket without TLS: nothing outside this container
# reaches it.
ENV DOCKER_TLS_CERTDIR=

COPY image/lsdc /usr/local/bin/lsdc
COPY VERSION /usr/local/share/lsd-cluster/VERSION

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
	CMD docker info >/dev/null 2>&1 || exit 1

LABEL org.opencontainers.image.title="lsd-cluster" \
      org.opencontainers.image.description="Several lsd-docker servers in one container, administered with lsdc" \
      org.opencontainers.image.source="https://github.com/Fran6nd/lsd-cluster" \
      org.opencontainers.image.licenses="GPL-3.0-or-later"
