#!/usr/bin/env bash

# @file cloud-torrent.sh
# @brief to install docker cloud-torrent


# @description create docker heimdall
# https://github.com/jpillora/cloud-torrent
# @args $2 USERNAME admin
# @args $3 PASSWORD password
# @exitcode 0 If successfull.
# @exitcode 1 On failure
 create_docker_cloud-torrent(){
    local USERNAME=${1:-"cloud-torrent"}
    local PASSWORD=${1:-"cloud-torrent"}
    udocker_create_dir "$PATH_DOWNLOAD"

    docker build -f "$(dirname "${BASH_SOURCE[0]}")/Dockerfile" --build-arg USERNAME="$USERNAME" PASSWORD="$PASSWORD"
    docker-compose -f "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/docker-compose.yml" up -d

    echo "ctrl+click to open in browser"
    echo "$(get_current_ip):6889"


    return 0
}