#!/bin/bash

. common.sh

if [[ $# -ne 2 ]]; then
    printf "Usage:\n\tbash $0 <osd id> <osd device>\n"
    printf "Example:\n\tbash $0 6 /dev/vdb\n"
    exit 1
fi

osd_id="$1"
osd_device=$2
pfn="ceph-osd --cluster=${cluster:-ceph} -i $osd_id --setuser ceph --setgroup ceph"

doCommand ceph osd out $osd_id
stop_process "$pfn"
doCommand sudo ceph osd crush remove osd.$osd_id
doCommand sudo ceph auth del osd.$osd_id
doCommand sudo ceph osd rm $osd_id
doCommand sudo umount $osd_device
