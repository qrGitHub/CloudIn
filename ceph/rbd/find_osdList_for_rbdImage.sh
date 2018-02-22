#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    printf "Usage:\n\t%s <pool name> <rbd image name>\n" "$0"
    exit 1
fi

pool_name=$1
dev_name=$2

find_rbd_prefix() {
    local pool_name=$1 dev_name=$2 rbd_info

    rbd_info=$(rbd info $pool_name/$dev_name)
    echo "$rbd_info" | grep -w block_name_prefix | awk -F[:.] '{print $NF}'
}

find_osdList_for_object() {
    local pool_name=$1 object=$2

    ceph osd map $pool_name $object | grep -Eo "\[[0-9,]+\]" | head -n 1 | grep -Eo [0-9,]+
}

rbd_prefix=$(find_rbd_prefix $pool_name $dev_name)

for object in $(rados -p $pool_name ls | grep $rbd_prefix | sort)
do
    echo -n "$object "
    find_osdList_for_object $pool_name $object
done
