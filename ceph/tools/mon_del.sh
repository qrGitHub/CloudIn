#!/bin/bash

if [[ $# -ne 1 ]]; then
    printf "Usage:\n\tbash %s <mon id>\n" "$0"
    printf "Example:\n\tbash %s YUNTU-CLOUD-01-04\n" "$0"
    exit 1
fi

mon_id="$1"

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1
}

doCommand stop ceph-mon id="$mon_id"
doCommand ceph mon remove "$mon_id"
