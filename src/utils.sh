#!/usr/bin/env bash
#
# @file utils.sh
# @brief file containing the utils  for the project and other

# @description print line ======
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
print_line() {
    printf "%0$(tput cols)d" 0 | tr '0' '='
    return 0
}

# @description print newline
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
print_newline() {
    printf "\n"
    return 0
}

# @description show aliases in the current shell
# Detect Operating System
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
dist_check() {
    DIST_CHECK="/etc/os-release"
    # shellcheck disable=SC1090
    if [ -e $DIST_CHECK ]; then
        # shellcheck disable=SC1091
        source $DIST_CHECK
        DISTRO=$ID
        # shellcheck disable=SC2034
        VERSION=$VERSION_ID
        export DISTRO
        export VERSION
    else
        echo "Your distribution is not supported (yet)."
        exit
    fi
}

# @description show aliases in the current shell
# Checking For Virtualization
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
virt_check() {
    if [[ $(command -v "systemd-detect-virt") ]]; then
        if [[ $(systemd-detect-virt) == "none" ]]; then
            return 1
        elif [[ $(systemd-detect-virt) == "wsl" ]] || [[ $(systemd-detect-virt) == "docker" ]]; then
            return 0
        fi
    else
        return 1
    fi
}

# @description check if the system is a WSL
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
checkWSL() {
    if [ -z "$WSL_DISTRO_NAME" ]; then
        return 1
    else
        return 0
    fi
}

# @description check for args for a
#
# @args $@ args
# @exitcode 0 If successfull.
# @exitcode 1 On failure
check_args() {
    if [[ "$#" -eq 0 ]]; then
        return 1
    fi
    return 0
}

# @description check root user
#
# @arg $1 a bash command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
check_root() {
    if [[ "$UID" -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

# @description check if the user is root then execute the command
#
# @arg $1 a bash command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
exec_root() {
    local command="$*"
    if [[ ! "$#" -eq 0 ]]; then
        if [[ "$UID" -gt 0 ]]; then
            echo "sudo $command"
            sudo $command
        else
            echo "$command"
            $command
        fi
        return 0
    fi
    return 1

}

# @description check if the user is root then execute the bash func
#
# @arg $1 a bash func
# @exitcode 0 If successfull.
# @exitcode 1 On failure
exec_root_func() {
    local func="$*"
    if [[ ! "$#" -eq 0 ]]; then
        if [[ "$UID" -gt 0 ]]; then
            sudo bash -c "$(declare -f ${func}); ${func}"
        else
            bash -c "$(declare -f ${func}); ${func}"
        fi
        # shellcheck disable=SC2086

        return 0
    fi
    return 1

}

# @description check if the packages exist
#
# @args $1 package name
# @exitcode 0 If installed
# @exitcode 1 if not installed
check_packages_install() {
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        # Get the number of packages installed that match $1
        local num=$(dpkg -l "$1" 2>/dev/null | egrep '^ii' | wc -l)
        if [[ $num -eq 1 ]]; then
            return 0
        elif [[ $num -gt 1 ]]; then
            return 0
        else
            return 1
        fi
    else
        local output=$(which "$1")
        return $?
    fi
}

# @description apt-get update
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
aptupdate() {
    echo "apt update"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq update" >/dev/null
        exec_root "apt-get -qq install -f" >/dev/null
        exec_root "apt-get -qq autoclean -y" >/dev/null
        exec_root "apt-get -qq autoremove -y" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Syy --noconfirm" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf check-update -y" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum check-update -y" >/dev/null
        return 0
    fi
    return 1
}

# @description upgrade all
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
aptupgrade() {
    echo "apt upgrade"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq update" >/dev/null
        exec_root "apt-get -qq upgrade" >/dev/null
        exec_root "apt-get -qq dist-upgrade" >/dev/null
        exec_root "apt-get -qq install -f" >/dev/null
        exec_root "apt-get -qq autoclean" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Su --noconfirm" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf upgrade -y" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum update -y" >/dev/null
        return 0
    fi
    return 1
}

# @description install package
#
# @args $@ packages to install
# @exitcode 0 If successfull.
# @exitcode 1 On failure
aptinstall() {
    echo "apt install $@"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "apt-get -qq install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "pacman -Syu --noconfirm $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "dnf install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "yum install -y $var" >/dev/null
        done
        return 0
    fi
    return 1
}

# @description remove package
#
# @args $@ packages to remove
# @exitcode 0 If successfull.
# @exitcode 1 On failure
aptremove() {
    echo "apt remove $@"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "apt-get remove -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "pacman -R --noconfirm $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "dnf erase -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        aptupdate >/dev/null
        for var in "$@"; do
            exec_root "yum remove -y $var" >/dev/null
        done
        return 0
    fi
    return 1
}

# @description apt-get autoclean
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
aptclean() {
    echo "apt clean"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq install -f" >/dev/null
        exec_root "apt-get -qq autoclean -y" >/dev/null
        exec_root "apt-get -qq autoremove -y" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        return 0
    fi
    if [ "$DISTRO" == "centos" ] && [ "$DISTRO" == "redhat" ]; then
        return 0
    fi
    return 1
}

# @description get timezone
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
get_timezones() {
    export TZ="$(cat /etc/timezone)"
    echo "$TZ"
    return 0
}

# @description check if the port is used
#
# @args $1 command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
check_command_exist() {
    if [[ $(command -v "$1") ]]; then
        return 0
    else
        return 1
    fi
}

# @description check if the port is used
#
# @args $1 port number
# @exitcode 0 If successfull.
# @exitcode 1 On failure
check_port() {
    if exec_root "lsof -i:$1 -P -n -t >/dev/null"; then
        return 0
    else
        return 1
    fi
}

# @description check if the port is used
#
# @args $# username of the user you want to add
# @exitcode 0 If successfull.
# @exitcode 1 On failure
add_sudo() {
    while [[ -n $1 ]]; do
        exec_root "usermod -aG sudo $1"
        echo '$1 ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo
        shift # shift all parameters;
    done
    return 0
}

# @description simple scp for downloading file for a remote dir scp/ssh
#
# @args $1 path to folder
# @exitcode 0 If successfull.
# @exitcode 1 On failure
chmod_sh_all() {
    find $1 -name "*.sh" -execdir chmod u+x {} +
}

# @description loop find files func
#
# @args $1 path to folder
# @args $2 regex of files
# @args $3 func
# @exitcode 0 If successfull.
# @exitcode 1 On failure
loop_files_func() {
    local names=$(find "$1" -name "$2")

    local SAVEIFS="$IFS" # Save current IFS
    local IFS=$'\n'      # Change IFS to new line
    local names=($names) # split to array $names
    local IFS="$SAVEIFS" # Restore IFS

    for ((i = 0; i < ${#names[@]}; i++)); do
        echo "$i: ${names[$i]}"
        $3 "${names[$i]}"
    done

    return 0
}

# @description show aliases in the current shell
# https://riptutorial.com/bash/topic/368/aliasing
# @noargsW
# @exitcode 0 If successfull.
# @exitcode 1 On failure
show_aliases() {
    echo There are ${#BASH_ALIASES[*]} aliases defined.
    for ali in "${!BASH_ALIASES[@]}"; do
        printf "alias: %-10s triggers: %s\n" "$ali" "${BASH_ALIASES[$ali]}"
    done
}

# @description check the geolocation based on ip of the server
# https://www.howtogeek.com/405088/how-to-get-your-systems-geographic-location-from-a-bash-script/
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
get_geolocation() {
    get_current_ip
    curl -s https://ipvigilante.com/${PUBLIC_IP} | jq '.data.latitude, .data.longitude, .data.city_name, .data.country_name' |
        while read -r LATITUDE; do
            read -r LONGITUDE
            read -r CITY
            read -r COUNTRY
            echo "${LATITUDE},${LONGITUDE},${CITY},${COUNTRY}"
        done

    #cp geolocate.sh /etc/cron.daily
}

# @description check the ip of the server
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
get_current_ip() {
    PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
    export PUBLIC_IP
    echo $PUBLIC_IP
}
