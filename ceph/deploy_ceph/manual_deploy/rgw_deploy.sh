#!/bin/bash

. common.sh

prepare_rgw_dir() {
    local name="$1"
    local rgw_dir="/var/lib/ceph/radosgw/ceph-rgw.${name}"

    doCommand sudo mkdir -p "$rgw_dir"
    doCommand sudo ceph auth get-or-create client.rgw.${name} osd 'allow rwx' mon 'allow rw' -o "${rgw_dir}/keyring"
    doCommand sudo touch "${rgw_dir}/done"
    doCommand sudo chown -R ceph:ceph "$rgw_dir"
}

prepare_rgw_dir $(hostname)
