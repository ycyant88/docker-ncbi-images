# syntax=docker.io/docker/dockerfile:1

ARG ubuntu_version

FROM index.docker.io/library/ubuntu:${ubuntu_version}

ARG version
ARG edirect_version="${version}"
ARG ubuntu_version

ENV EDIRECT_VERSION="${edirect_version}" \
    HOME="/workspace" \
    LANG="C" \
    LC_ALL="C" \
    PATH="/workspace/edirect:${PATH}" \
    TZ="UTC" \
    UBUNTU_VERSION="${ubuntu_version}"

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
    && echo UTC > /etc/timezone \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get install -y --no-install-recommends \
           curl \
           libxml-simple-perl \
           libwww-perl \
           libnet-perl \
           build-essential \
    && rm -rf /var/lib/apt/lists/*

USER root
WORKDIR /workspace

COPY --chown=root:root --chmod=755 installconfirm /workspace

RUN sh -c "$(curl -fsSL https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)" \
    && sed -i 's/^http_version="1\.0"$/http_version="1.1"/' /workspace/edirect/nquire \
    && bash /workspace/installconfirm
