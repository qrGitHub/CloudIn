#!/bin/bash

. common.sh

rgw_id=rgw.$(hostname)
pfn="radosgw --cluster=${cluster:-ceph} --id $rgw_id --setuser ceph --setgroup ceph"

restart_process "$pfn"
sleep 3
>/var/log/ceph/ceph-client.${rgw_id}.log
