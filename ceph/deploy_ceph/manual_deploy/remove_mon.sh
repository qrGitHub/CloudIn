#!/bin/bash

. common.sh

if [[ $# -ne 1 ]]; then
    printf "Usage:\n\tbash %s <mon id>\n" "$0"
    printf "Example:\n\tbash %s YUNTU-CLOUD-01-04\n" "$0"
    exit 1
fi

mon_id="$1"
pfn="ceph-mon --cluster=${cluster:-ceph} -i $mon_id --setuser ceph --setgroup ceph"

stop_process "$pfn"
#doCommand ceph mon remove "$mon_id"
doCommand rm -rf /var/lib/ceph/mon/ceph-${mon_id}
