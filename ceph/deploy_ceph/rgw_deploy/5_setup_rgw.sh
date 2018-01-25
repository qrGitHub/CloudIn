#!/bin/bash
set -x
set -e

prepare_rgw_dir() {
    local name="$1"
    local rgw_dir="/var/lib/ceph/radosgw/ceph-rgw.${name}"

    mkdir -p "$rgw_dir"
    ceph auth get-or-create client.rgw.${name} osd 'allow rwx' mon 'allow rw' -o "${rgw_dir}/keyring"
    touch "${rgw_dir}/done"
    chown -R ceph:ceph "$rgw_dir"
}

tag_list=(lan0 wan0)
for tag in ${tag_list[@]}
do
    rgw_name=$(hostname).${tag}
    prepare_rgw_dir $rgw_name
    start radosgw id=rgw.$rgw_name
done
