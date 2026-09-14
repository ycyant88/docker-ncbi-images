#!/bin/bash
# Update image versions from the NCBI ftp site

set -e

echo "==> Running $(dirname "$(realpath "$0")")/update.sh"

update_edirect_version()
{
    local latest_versions=""

    latest_versions=$(curl -s "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/versions/" |
        sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' |
        sort -V |
        sed -n '/^22\.0\./,$p') # > 22.0.*
    echo "${latest_versions}" | head -n 1 > .edirect-version
    echo "${latest_versions}" > .edirect-versions
}

update_ubuntu_version()
{
    local image_registry_url="https://hub.docker.com/v2/repositories/library/ubuntu/tags?page_size=100"

    while [[ -n "${image_registry_url}" ]]; do
        response=$(curl -fsSL "${image_registry_url}")

        latest_versions+=$(
            jq -r '.results[].name' <<< "${response}"
        )
        latest_versions+=$'\n'

        image_registry_url=$(jq -r '.next // empty' <<< "${response}")
    done

    latest_versions=$(
        printf '%s' "${latest_versions}" |
        grep -E '^[0-9]+\.04$' |
        awk -F. '$1 > 20 && $1 % 2 == 0' |
        sort -Vr
    )

    echo "${latest_versions}" | head -n 1 > .ubuntu-version
    echo "${latest_versions}" > .ubuntu-versions
}

update_edirect_version
update_ubuntu_version
