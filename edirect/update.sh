#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/update.sh"

update_entrez_versions()
{
    curl -s https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/versions/ |
        sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' |
        sort -V |
        sed -n '/^22\.0\./,$p' > .entrez-versions
    echo ".entrez-versions:" && cat .entrez-versions
}

update_entrez_version()
{
    curl -s https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/versions/ |
        sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' |
        sort -V |
        tail -1 > .entrez-version
    echo ".entrez-version:" && cat .entrez-version
}

update_entrez_version
update_entrez_versions
