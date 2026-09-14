# syntax=docker.io/docker/dockerfile:1

ARG ubuntu_version

FROM index.docker.io/library/ubuntu:${ubuntu_version} AS base

ARG version
ARG edirect_version="${version}"
ARG ubuntu_version
ARG username=docker
ARG grpname=docker

ENV EDIRECT_VERSION="${edirect_version}" \
    EMAIL="docker@ncbi.nlm.nih.gov" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    PATH="/home/${username}/edirect:${PATH}" \
    TZ="Asia/Singapore" \
    UBUNTU_VERSION="${ubuntu_version}"

RUN groupadd ${grpname} \
    && useradd --no-log-init -r -g ${grpname} ${username} \
    && mkdir -vp /home/${username} \
    && chown -Rc ${username}:${grpname} /home/${username}

USER ${username}
WORKDIR /home/${username}/

FROM base

RUN apt update \
    && apt install -y curl libxml-simple-perl libwww-perl libnet-perl build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && sh -c "$(curl -fsSL https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"

COPY --chown=${username}:${grpname} installconfirm /home/${username}/

CMD ["/bin/bash"]
