#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/update.sh"

update_blast_versions()
{
    curl -s https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/ |
        sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' |
        sort -V |
        sed -n '/^2.14.1$/,$p' > .blast-versions
    echo ".blast-versions:" && cat .blast-versions
}

update_blast_version()
{
    curl -s https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/ |
        sed -nE 's/.*href="([0-9]+\.[0-9]+\.[0-9]+)\/".*/\1/p' | 
        sort -V |
        tail -1 > .blast-version
    echo ".blast-version:" && cat .blast-version
}

update_blast_version
update_blast_versions
