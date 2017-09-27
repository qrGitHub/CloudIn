#!/bin/bash

if [[ $# -ne 2 ]]; then
    printf "Usage:\n\tbash %s <mon id> <mon ip>\n" "$0"
    printf "Example:\n\tbash %s YUNTU-CLOUD-01-04 172.16.0.13\n" "$0"
    exit 1
fi

map_file="/tmp/monmap"
mon_id="$1"
mon_ip="$2"

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1
}

# Create the default directory on the machine that will host the new monitor.
doCommand mkdir -p /var/lib/ceph/mon/ceph-"$mon_id"

# Retrieve the monitor map
doCommand ceph mon getmap -o "$map_file"

# Prepare the monitor’s data directory created in the first step.
#mon_keyring="/tmp/monkeyring"                                                          # 如开启cephx
#doCommand ceph auth get mon. -o "$mon_keyring"                                         # 如开启cephx
#doCommand ceph-mon -i "$mon_id" --mkfs --monmap "$map_file" --keyring "$mon_keyring"   # 如开启cephx
doCommand ceph-mon -i "$mon_id" --mkfs --monmap "$map_file"                             # 未开启cephx

# Start the new monitor and it will automatically join the cluster.
doCommand ceph-mon -i "$mon_id" --public-addr "$mon_ip"
