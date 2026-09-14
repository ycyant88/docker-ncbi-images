# syntax=docker.io/docker/dockerfile:1

ARG ubuntu_version

FROM index.docker.io/library/ubuntu:${ubuntu_version}

ARG version
ARG edirect_version="${version}"
ARG ubuntu_version
ARG username=docker
ARG groupname=docker

ENV EDIRECT_VERSION="${edirect_version}" \
    EMAIL="docker@ncbi.nlm.nih.gov" \
    LANG="C" \
    LC_ALL="C" \
    PATH="/home/${username}/edirect:${PATH}" \
    TZ="Asia/Singapore" \
    UBUNTU_VERSION="${ubuntu_version}"

RUN apt update \
    && apt install -y sudo curl ca-certificates openssl libxml-simple-perl libwww-perl libnet-perl build-essential \
    && rm -rf /var/lib/apt/lists/* 

RUN groupadd ${groupname} \
    && useradd --no-log-init -r -g ${groupname} ${username} \
    && mkdir -vp /home/${username} \
    && chown -Rc ${username}:${groupname} /home/${username}

USER ${username}
WORKDIR /home/${username}/

COPY --chown=${username}:${groupname} --chmod=755 installconfirm /home/${username}/

RUN sh -c "$(curl -fsSL https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)" \
    && sed -i 's/^http_version="1\.0"$/http_version="1.1"/' /home/${username}/edirect/nquire \
    && bash /home/${username}/installconfirm

CMD ["/bin/bash"]
