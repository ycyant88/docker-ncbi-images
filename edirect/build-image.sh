#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/build_all.sh"

function cleanup()
{
    echo "==> Cleaning up..."
    docker buildx rm "$docker_builder" || true
}

function docker_init()
{
    docker_builder="builder-$(openssl rand -hex 4)"

    docker --version
    docker buildx version
    docker buildx create --name "${docker_builder}" --bootstrap --use
}

function build_all()
{
    trap cleanup EXIT INT TERM
    docker_init

    local image_name="edirect"
    local image_registry="index.docker.io/ycyant88"

    edirect_versions="$(sort -V .edirect-versions)"
    ubuntu_versions="$(sort -V .ubuntu-versions)"

    while read -r UBUNTU_VERSION; do
        while read -r EDIRECT_VERSION; do
            export EDIRECT_VERSION="${EDIRECT_VERSION}"
            export IMAGE_NAME="${image_name}"
            export IMAGE_REGISTRY="${image_registry}"
            export IMAGE_TAG="${EDIRECT_VERSION}-ubuntu${UBUNTU_VERSION}"
            export UBUNTU_VERSION="${UBUNTU_VERSION}"

            echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}..."

            docker buildx bake push --no-cache

        done <<< "${edirect_versions}"
    done <<< "${ubuntu_versions}"
}

"$@"
