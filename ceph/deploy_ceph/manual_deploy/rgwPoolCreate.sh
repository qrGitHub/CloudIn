#!/bin/bash

pool_create() {
    ceph osd pool create "$1" "$2" "$2"
}

rgw_root_create() {
    ceph osd pool ls | grep -w "\.rgw\.root" > /dev/null
    if [ $? -ne 0 ]; then
        pool_create .rgw.root 8
    fi
}

rgw_pool_create_0_94_5() {
    pool_create .rgw.root 64
    pool_create .rgw.control 64
    pool_create .rgw 64
    pool_create .rgw.gc 64
    pool_create .users.uid 64
    pool_create .users 64
    pool_create .users.email 64
    pool_create .rgw.buckets.index 128
    pool_create .rgw.buckets 128
}

rgw_pool_create_10_2_5() {
    rgw_root_create

    pool_create ${1}.rgw.control 8
    pool_create ${1}.rgw.data.root 8
    pool_create ${1}.rgw.gc 8
    pool_create ${1}.rgw.log 8
    pool_create ${1}.rgw.intent-log 8
    pool_create ${1}.rgw.meta 8
    pool_create ${1}.rgw.usage 8
    pool_create ${1}.rgw.users.swift 8
    pool_create ${1}.rgw.rgw.buckets.extra 16
    pool_create ${1}.rgw.users.keys 8
    pool_create ${1}.rgw.users.email 8
    pool_create ${1}.rgw.users.uid 8
    pool_create ${1}.rgw.buckets.index 32
    pool_create ${1}.rgw.buckets.data 256
    pool_create ${1}.rgw.buckets.non-ec 32
}

rgw_pool_create_12_2_1() {
    rgw_root_create

    pool_create ${1}.rgw.control 8
    pool_create ${1}.rgw.data.root 8
    pool_create ${1}.rgw.gc 8
    pool_create ${1}.rgw.log 8
    pool_create ${1}.rgw.intent-log 8
    pool_create ${1}.rgw.meta 8
    pool_create ${1}.rgw.usage 8
    pool_create ${1}.rgw.users.swift 8
    pool_create ${1}.rgw.rgw.buckets.extra 16
    pool_create ${1}.rgw.users.keys 8
    pool_create ${1}.rgw.users.email 8
    pool_create ${1}.rgw.users.uid 8
    pool_create ${1}.rgw.buckets.index 32
    pool_create ${1}.rgw.buckets.data 256
    pool_create ${1}.rgw.buckets.non-ec 32

    ceph osd pool ls | grep .rgw. | xargs -n 1 -I {} ceph osd pool application enable {} rgw
}

zone=${1:-default} && rgw_pool_create_12_2_1 $zone
