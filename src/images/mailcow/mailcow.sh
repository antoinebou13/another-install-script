#!/usr/bin/env bash
#
# @file mailcow.sh
# @brief to install dockermailcow

# @description create docker mailcow
# https://github.com/mailcow/mailcow-dockerized
# https://mailcow.github.io/mailcow-dockerized-docs/i_u_m_install/
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
 create_docker_mailcow(){
    udocker_create_dir /home/udocker/volumes/mailcow
    pushd /home/udocker/volumes/mailcow
    git clone https://github.com/mailcow/mailcow-dockerized
    pushd mailcow-dockerized 
    ./generate_config.sh
    nano mailcow.conf
    nano docker-compose.yml
    exec_root docker-compose pull
    exec_root docker-compose up -d
    popd
    popd
    return 0
}