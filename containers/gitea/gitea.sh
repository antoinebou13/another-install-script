#!/usr/bin/env bash

# @file gitea.sh
# @brief to install docker gitea

# @description create docker gitea
# not implemented yet
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_gitea() {

    docker-compose -f "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/docker-compose.yml" up -d

    echo "ctrl+click to open in browser"
    echo "$(get_current_ip):3000"

    return 0
}

# @description remove docker gitea
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
remove_docker_gitea() {
    docker-compose -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/docker-compose.yml" down
    return 0
}