#!/bin/bash

case $1 in
    --no-cleanup)
        cleanup=0
        ;;
    -h)
        printf "Usage:\n\t%s [--no-cleanup|-h]\n" "$0"
        exit 1
        ;;
    *)
        cleanup=1
        ;;
esac

. common.sh

rgw_id=rgw.$(hostname)
pfn="radosgw --cluster=${cluster:-ceph} --id $rgw_id --setuser ceph --setgroup ceph"

restart_process "$pfn"

if [ $cleanup -eq 1 ]; then
    sleep 3
    >/var/log/ceph/ceph-client.${rgw_id}.log
fi
