#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    #eval "$@"
    [[ $? -eq 0 ]] || exit 1
}

if [[ $# -ne 2 ]]; then
    printf "Usage:\n\tbash $0 <osd id> <osd device>\n"
    printf "Example:\n\tbash $0 6 /dev/vdb\n"
    exit 1
fi

osdID=$1
osdDevice=$2

doCommand ceph osd out $osdID
echo "Wait until the migration completes"
doCommand sudo stop ceph-osd id=$osdID
doCommand sudo ceph osd crush remove osd.$osdID
doCommand sudo ceph auth del osd.$osdID
doCommand sudo ceph osd rm $osdID
doCommand sudo umount $osdDevice
echo "Modify file /etc/ceph/ceph.conf and scp it to other hosts"
