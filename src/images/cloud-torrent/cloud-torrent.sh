#!/usr/bin/env bash

# @file cloud-torrent.sh
# @brief to install docker cloud-torrent

# @description create docker heimdall
# https://github.com/jpillora/cloud-torrent
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_cloud-torrent() {
    local USERNAME=${1:-"cloud-torrent"}
    local PASSWORD=${1:-"cloud-torrent"}
    udocker_create_dir "$PATH_DOWNLOAD"

    docker build -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/Dockerfile" --build-arg USERNAME="$USERNAME" PASSWORD="$PASSWORD"
    docker-compose -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/docker-compose.yml" up -d

    echo "ctrl+click to open in browser"
    echo "$(get_current_ip):6889"

    return 0
}

# @description remove docker cloud-torrent
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
remove_docker_cloud-torrent() {
    echo "not implemented"
    return 0
}