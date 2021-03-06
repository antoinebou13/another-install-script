#!/usr/bin/env bash
#
# @file firewall.sh
# @brief to manage the open port in the firewall

# import
# shellcheck source=config.sh
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/config.sh"
# shellcheck source=utils.sh
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/utils.sh"

# @description install firewall
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
install_firewall() {
    if ! check_packages_install ufw; then
    
        aptinstall ufw
        exec_root ufw default deny incoming
        exec_root ufw default allow outgoing
        allow_port_in_firewall ssh
        allow_port_in_firewall 2222
        allow_port_in_firewall http
        allow_port_in_firewall https
        enable_firewall
    fi
    return 0
}

# @description uninstalll firewall
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
uninstall_firewall() {
    if check_packages_install ufw; then
        disable_firewall
        aptremove ufw
        return 0
    else
        return 0
    fi
}

# @description enable firewall
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
enable_firewall() {
    if check_packages_install ufw; then
        if checkWSL && virt_check; then
            exec_root ufw --force enable
        fi
        return 0
    else
        return 1
    fi
}

# @description disable firewall
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
disable_firewall() {
    if check_packages_install ufw; then
        if checkWSL && virt_check; then
            exec_root ufw disable
        fi
        return 0
    else
        return 1
    fi
}

# @description allow a port in the firewall
#
# @args $1 port to allow
# @exitcode 0 If successfull.
# @exitcode 1 On failure
allow_port_in_firewall() {
    if check_packages_install ufw; then
        exec_root ufw allow "$1" >/dev/null
        return 0
    else
        return 1
    fi
}

# @description deny a port in the firewall
#
# @args $1 port to deny
# @exitcode 0 If successfull.
# @exitcode 1 On failure
deny_port_in_firewall() {
    if check_packages_install ufw; then
        exec_root ufw deny "$1"
        return 0
    else
        return 1
    fi
}

# @description manage allow port based on installed containers
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
manage_firewall_ports_allow_list() {

	if read_config_yml system_udocker_username; then
        local UDOCKER="$(read_config_yml system_udocker_username)"
        local UDOCKER="${UDOCKER//\"/}"
        local UDOCKER=${UDOCKER//[[:blank:]]/} >/dev/null
    else
        local UDOCKER="udocker"
    fi

    containers=()
    if [[ -f /home/udocker/config/containers.txt ]]; then
        mapfile -t containers <<<"$(cat /home/$UDOCKER/config/containers.txt)"
    elif [[ -f /tmp/containers.txt ]]; then
        mapfile -t containers <<<"$(cat /tmp/containers.txt)"
    fi

    for container_name in "${containers[@]}"; do
        parse_yml_array_ports "$container_name"
        echo "$(parse_yml_array_ports "$container_name")" | exec_root tee -a /tmp/ports.txt
    done

    [ -d /home/"$UDOCKER"/ ] && exec_root cp /tmp/ports.txt /home/"$UDOCKER"/config/ports.txt

    ports=()
    if [[ -f /home/udocker/config/ports.txt ]]; then
        mapfile -t ports <<<"$(cat /home/$UDOCKER/config/ports.txt)"
    elif [[ -f /tmp/ports.txt ]]; then
        mapfile -t ports <<<"$(cat /tmp/ports.txt)"
    fi

    for port_numbers in "${ports[@]}"; do
        echo "allow $port_numbers"
        allow_port_in_firewall "$port_numbers"
    done

    if [[ "$(read_config_yml "system_firewall")" == "yes" ]]; then
        install_firewall
    else
        disable_firewall
    fi

    return 0
    print_line
}

# @description manage deny port based on uninstalled containers
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
manage_firewall_ports_deny_list() {
    return 1
}
