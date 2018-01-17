#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$@"
    [[ $? -eq 0 ]] || exit 1
}

if [ $# -ne 1 ]; then
    printf "Usage:\n\t%s <trove id>\n" "$0"
    exit 1
fi

ID="$1"

mysql -uopenstack -pb1526b0c -h 10.10.1.205 -e "update trove.instances set virtual_ip_vrid=NULL where id='$ID';"
doCommand trove delete "$ID"
