#!/bin/bash

. common.sh

mon_id=$(hostname)
pfn="ceph-mon --cluster=${cluster:-ceph} -i $mon_id --setuser ceph --setgroup ceph"

>/var/log/ceph/ceph-mon.${mon_id}.log
restart_process "$pfn"
