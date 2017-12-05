#!/bin/bash

pool_delete() {
    ceph osd pool delete "$1" "$1" --yes-i-really-really-mean-it
}

rgw_root_delete() {
    ceph osd pool ls | grep "\.rgw\.control" > /dev/null
    if [ $? -ne 0 ]; then
        pool_delete .rgw.root
    fi
}

rgw_pool_delete_0_94_5() {
    pool_delete .rgw.buckets
    pool_delete .rgw.buckets.index
    pool_delete .users.email
    pool_delete .users
    pool_delete .users.uid
    pool_delete .rgw.gc
    pool_delete .rgw
    pool_delete .rgw.control
    pool_delete .rgw.root
}

rgw_pool_delete_10_2_5() {
    pool_delete ${1}.rgw.buckets.non-ec
    pool_delete ${1}.rgw.buckets.data
    pool_delete ${1}.rgw.buckets.index
    pool_delete ${1}.rgw.users.uid
    pool_delete ${1}.rgw.users.email
    pool_delete ${1}.rgw.users.keys
    pool_delete ${1}.rgw.intent-log
    pool_delete ${1}.rgw.meta
    pool_delete ${1}.rgw.usage
    pool_delete ${1}.rgw.users.swift
    pool_delete ${1}.rgw.rgw.buckets.extra
    pool_delete ${1}.rgw.log
    pool_delete ${1}.rgw.gc
    pool_delete ${1}.rgw.data.root
    pool_delete ${1}.rgw.control

    rgw_root_delete
}

rgw_pool_delete_12_2_1() {
    rgw_pool_delete_10_2_5
}

zone=${1:-default} && rgw_pool_delete_12_2_1 $zone
