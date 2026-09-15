#!/bin/bash
# Update image versions from the NCBI ftp site

set -e

echo "Running $(dirname "$(realpath "$0")")/update-tags.sh"

function update_ubuntu()
{
    local latest_versions=""
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
        awk -F. '$1 > 19 && $1 % 2 == 0' |
        sort -Vr # > 19.04
    )

    printf '%s\n' "${latest_versions}" | head -n 1 > .ubuntu-version
    printf '%s\n' "${latest_versions}" > .ubuntu-versions

    echo ".ubuntu-version:"
    cat .ubuntu-version

    echo ".ubuntu-versions:"
    cat .ubuntu-versions

    cd - >/dev/null
}

function update_blast()
{
    local latest_versions=""

    cd src/blast || {
      echo "not found"
      exit 1
    }

    latest_versions=$(
    curl -fsSL "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/" |
        sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' |
        awk -F. '$1 == 2 && ($2 > 14 || ($2 == 14 && $3 >= 1))' |
        sort -Vr
    )

    printf '%s\n' "${latest_versions}" | head -n 1 > .blast-version
    printf '%s\n' "${latest_versions}" > .blast-versions

    echo ".blast-version:"
    cat .blast-version

    echo ".blast-versions:"
    cat .blast-versions

    update_ubuntu
}

function update_edirect()
{
    local latest_versions=""

    cd src/edirect || {
      echo "not found"
      exit 1
    }

    latest_versions=$(
        curl -fsSL "https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/versions/" |
            sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' |
            awk -F. '$1 > 22 || ($1 == 22 && $2 > 0)' |
            sort -Vr
    )

    printf '%s\n' "${latest_versions}" | head -n 1 > .edirect-version
    printf '%s\n' "${latest_versions}" > .edirect-versions

    echo ".edirect-version:"
    cat .edirect-version

    echo ".edirect-versions:"
    cat .edirect-versions

    update_ubuntu
}

update_blast
update_edirect
