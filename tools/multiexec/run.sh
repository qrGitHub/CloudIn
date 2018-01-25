#!/bin/bash

#multiexec -u root -f /home/openstack/qr/batch/physical_host "$@"
if [ $# -lt 2 ]; then
    printf "Usage:\n\tbash $0 <FILE> <COMMAND>\n" "$0"
    exit 0
fi

FILE=$1
shift

multiexec -u root -f $FILE "$@"
