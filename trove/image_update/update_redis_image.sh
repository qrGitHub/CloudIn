#!/bin/bash

. ./common-functions || exit 1

if [ $# -ne 1 ]; then
    printf "Usage:\n\t%s <tag>\n" "$0"
    printf "Example:\n\t%s v0.0.1\n" "$0"
    exit 1
else
    tag="$1"
fi

source /opt/osdeploy/admin_openrc.sh
doCommand glance image-update --name docker.cloudin.com/trove/redis:"$tag" 78ea35c6-ad89-4282-90c6-db6f9444bd3e
