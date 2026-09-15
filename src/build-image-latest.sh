#!/bin/bash

set -e

echo "Running $(dirname "$(realpath "$0")")/build-image-latest.sh"

function cleanup()
{
    echo "Cleaning up"
    docker buildx rm "$docker_builder" || true
}

function docker_init()
{
    date="$(date -Iseconds)"
    docker_builder="builder-$(openssl rand -hex 4)"
    docker --version
    docker buildx version
    docker buildx create --name "${docker_builder}" --bootstrap --use
}

function check_dockerhub_tags()
{
    local namespace="$1"
    local repository="$2"
    local tag="$3"

    curl -fsSL \
        "https://hub.docker.com/v2/namespaces/${namespace}/repositories/${repository}/tags?page_size=100" |
        jq -e --arg tag "${tag}" \
            '.results[] | select(.name == $tag)' \
            > /dev/null
}

function build_image()
{
    trap cleanup EXIT INT TERM
    docker_init

    local image_name="$1"
    local image_namespace="ycyant88"
    local image_registry="index.docker.io"
    local image_version
    local ubuntu_version

    cd "src/${image_name}" || {
        echo "not found: src/${image_name}"
        exit 1
    }

    image_version="$(cat ".${image_name}-version")"
    ubuntu_version="$(cat ".ubuntu-version")"

    export "${image_name^^}_VERSION"="${image_version}"
    export DATE="${date}"
    export IMAGE_NAME="${image_name}"
    export IMAGE_NAMESPACE="${image_namespace}"
    export IMAGE_REGISTRY="${image_registry}"
    export IMAGE_TAG="${image_version}-ubuntu${ubuntu_version}"
    export UBUNTU_VERSION="${ubuntu_version}"

    if check_dockerhub_tags \
        "${image_namespace}" \
        "${image_name}" \
        "${IMAGE_TAG}"
    then
        echo "Skipping ${image_registry}/${image_name}:${IMAGE_TAG} (already exists)"
    else
        echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}"
        docker buildx bake push --no-cache
    fi
}

build_image "$1"