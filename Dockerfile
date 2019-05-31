FROM jenkins/jnlp-slave:3.27-1

ARG GOSU_VERSION=1.10
ARG DOCKER_CHANNEL=stable
ARG DOCKER_VERSION=18.06.1-ce
ARG TINY_VERSION=0.16.1

USER root

RUN apt-get update && apt-get -y install software-properties-common wget curl ca-certificates zlib1g apt-utils python-pip

ENV LANG=en_US.UTF-8

RUN \
    curl -SsLo /usr/bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 && \
    chmod +x /usr/bin/gosu && \
    curl -SsLo /usr/bin/tiny https://github.com/krallin/tini/releases/download/v${TINY_VERSION}/tini-amd64 && \
    chmod +x /usr/bin/tiny

RUN \
    curl -Ssl "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" | \
    tar -xz  --strip-components 1 --directory /usr/bin/  && \
    \
    pip install --no-cache-dir --upgrade docker-compose

COPY entrypoint.sh /entrypoint.sh

## https://github.com/docker-library/docker/blob/fe2ca76a21fdc02cbb4974246696ee1b4a7839dd/18.06/modprobe.sh
COPY modprobe.sh /usr/local/bin/modprobe
## https://github.com/jpetazzo/dind/blob/72af271b1af90f6e2a4c299baa53057f76df2fe0/wrapdocker
COPY wrapdocker.sh /usr/local/bin/wrapdocker

VOLUME /var/lib/docker

ENTRYPOINT [ "tiny", "--", "/entrypoint.sh" ]
