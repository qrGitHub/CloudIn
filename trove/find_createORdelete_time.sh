#!/bin/bash

if [ $# -eq 0 ]; then
    grep 'Create master instance' /var/log/cloud/openstack/trove/trove-taskmanager.log
elif [ "$1" == "delete" ]; then
    grep -E 'Setting instance [^ ]* to be deleted' /var/log/cloud/openstack/trove/trove-taskmanager.log
else
    printf "Usage:\n\t%s [delete]\n" "$0"
fi
