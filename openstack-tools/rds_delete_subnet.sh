#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ "${PIPESTATUS[0]}" -eq 0 ] || return 1
}

subnet_name2id() {
    line=$(neutron subnet-list | grep -w "$1")
    if [ $? -ne 0 ]; then
        return 1
    fi

    subnet_id=$(echo "$line" | awk '{print $2}')
}

get_port_attr() {
    line=$(neutron port-show "$1" | grep -w " $2 ")
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "$line" | awk -F'|' '{print $3}' | grep -o "[^ ]\+\( \+[^ ]\+\)*"
}

delete_port() {
    owner=$(get_port_attr "$1" device_owner)
    if [ $? -ne 0 ]; then
        # some port may not have device owner
        doCommand neutron port-delete "$1"
        return 0
    fi

    echo "$owner" | grep -q '^network:router_'
    if [ $? -eq 0 ]; then
        device_id=$(get_port_attr "$1" device_id)
        if [ $? -ne 0 ]; then
            printf "get port device_id for %s failed\n" "$1"
            return 1
        fi

        # leave router and delete port
        doCommand neutron router-interface-delete "$device_id" port="$1"
    else
        doCommand neutron port-delete "$1"
    fi
}

delete_port_for_subnet() {
    neutron port-list | grep -w "$1" | awk '{print $2}' | while read port_id
    do
        delete_port "$port_id"
        if [ $? -ne 0 ]; then
            printf "delete port %s failed\n" "$port_id"
            return 1
        fi
    done
}

if [ $# -ne 1 ]; then
    printf "Usage:\n\tbash %s <subnet name>\n" "$0"
    exit 1
else
    subnet="$1"
fi

source /opt/osdeploy/admin_openrc.sh

subnet_name2id "$subnet"
if [ $? -ne 0 ]; then
    printf "find subnet id for %s failed\n" "$subnet"
    exit 1
fi

delete_port_for_subnet "$subnet_id"
if [ $? -ne 0 ]; then
    printf "delete ports for subnet %s failed\n" "$subnet_id"
    exit 1
fi

doCommand neutron subnet-delete "$subnet_id"
