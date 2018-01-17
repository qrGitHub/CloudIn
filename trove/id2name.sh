#!/bin/bash

if [ $# -ne 1 ]; then
    printf "Usage:\n\tbash %s <container id>\n" "$0"
    exit 1
fi

nova_id=$(docker ps | grep ^"$1" | grep -Eo '[^- ]*-[^- ]*-[^- ]*-[^- ]*-[^- ]*$')
if [ -z "$nova_id" ]; then
    printf "find nova id for %s failed\n" "$1"
    exit 1
fi

source /opt/osdeploy/admin_openrc.sh
nova show "$nova_id" | grep -w name | awk '{print $4}'
