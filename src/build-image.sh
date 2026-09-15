#!/bin/bash

set -e

echo "Running $(dirname "$(realpath "$0")")/build-image.sh"

function cleanup()
{
    echo "Cleaning up"
    docker buildx rm "$docker_builder" || true
}

function docker_init()
{
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

function blast()
{
    trap cleanup EXIT INT TERM
    docker_init

    local image_name="blast"
    local image_namespace="ycyant88"
    local image_registry="index.docker.io"

    cd src/blast || {
      echo "not found"
      exit 1
    }

    blast_versions="$(sort -V .blast-versions)"
    ubuntu_versions="$(sort -V .ubuntu-versions)"

    while read -r UBUNTU_VERSION; do
        while read -r BLAST_VERSION; do
            export BLAST_VERSION="${BLAST_VERSION}"
            export DATE="${date}"
            export IMAGE_NAME="${image_name}"
            export IMAGE_NAMESPACE="${image_namespace}"
            export IMAGE_REGISTRY="${image_registry}"
            export IMAGE_TAG="${BLAST_VERSION}-ubuntu${UBUNTU_VERSION}"
            export UBUNTU_VERSION="${UBUNTU_VERSION}"

            if check_dockerhub_tags "${image_namespace}" "${image_name}" "${IMAGE_TAG}"; then
                echo "Skipping ${image_registry}/${image_name}:${IMAGE_TAG} (already exists)"
                continue
            fi

            echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}"
            docker buildx bake push --no-cache

        done <<< "${blast_versions}"
    done <<< "${ubuntu_versions}"
}

function edirect()
{
    trap cleanup EXIT INT TERM
    docker_init

    local image_name="edirect"
    local image_namespace="ycyant88"
    local image_registry="index.docker.io"

    cd src/edirect || {
      echo "not found"
      exit 1
    }

    edirect_versions="$(sort -V .edirect-versions)"
    ubuntu_versions="$(sort -V .ubuntu-versions)"

    while read -r UBUNTU_VERSION; do
        while read -r EDIRECT_VERSION; do
            export EDIRECT_VERSION="${EDIRECT_VERSION}"
            export DATE="${date}"
            export IMAGE_NAME="${image_name}"
            export IMAGE_NAMESPACE="${image_namespace}"
            export IMAGE_REGISTRY="${image_registry}"
            export IMAGE_TAG="${EDIRECT_VERSION}-ubuntu${UBUNTU_VERSION}"
            export UBUNTU_VERSION="${UBUNTU_VERSION}"

            if check_dockerhub_tags "${image_namespace}" "${image_name}" "${IMAGE_TAG}"; then
                echo "Skipping ${image_registry}/${image_name}:${IMAGE_TAG} (already exists)"
                continue
            fi

            echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}"
            docker buildx bake push --no-cache

        done <<< "${edirect_versions}"
    done <<< "${ubuntu_versions}"
}

"$@"
