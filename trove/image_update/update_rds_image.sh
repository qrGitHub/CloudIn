#!/bin/bash

. ./common-functions || exit 1

if [ $# -ne 1 ]; then
    printf "Usage:\n\t%s <tag>\n" "$0"
    printf "Example:\n\t%s 1.1.4\n" "$0"
    exit 1
else
    tag="$1"
fi

source /opt/osdeploy/admin_openrc.sh
doCommand glance image-update --name docker.cloudin.com/trove/rds:"$tag" a4889995-56fe-43b2-971c-3cad086b35b6
