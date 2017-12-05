#!/bin/bash

. common.sh

mgr_id=$(hostname)
pfn="ceph-mgr --cluster=${cluster:-ceph} -i $mgr_id --setuser ceph --setgroup ceph"

>/var/log/ceph/ceph-mgr.${mgr_id}.log
restart_process "$pfn"
