#!/bin/bash

. common.sh

if [ $# -ne 1 ]; then
    printf "Usage:\n\tbash %s <osd id>\n" "$0"
    exit 1
fi

osd_id="$1"
pfn="ceph-osd --cluster=${cluster:-ceph} -i $osd_id --setuser ceph --setgroup ceph"

>/var/log/ceph/ceph-osd.${osd_id}.log
restart_process "$pfn"
