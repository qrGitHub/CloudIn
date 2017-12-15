#!/bin/bash

. common.sh

if [[ $# -ne 1 ]]; then
    printf "Usage:\n\tbash %s <mgr id>\n" "$0"
    printf "Example:\n\tbash %s YUNTU-CLOUD-01-04\n" "$0"
    exit 1
fi

mgr_id="$1"
pfn="ceph-mgr --cluster=${cluster:-ceph} -i $mgr_id --setuser ceph --setgroup ceph"

stop_process "$pfn"
doCommand rm -rf /var/lib/ceph/mgr/ceph-${mgr_id}
