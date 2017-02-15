#!/bin/bash

device_list=(/dev/sde3 /dev/sdb5)
host_list=$(cat host_list)

get_uuid() {
    res=$(ssh "$1" sudo blkid "$2")
    echo "$res" | awk -F'"' '{print $2}'
}

get_mountpoint() {
    res=$(ssh "$1" "df | grep $2")
    echo "$res" | awk '{print $6}'
}

generate_fstab_item() {
    uuid=$(get_uuid "$1" "$2")
    mountpoint=$(get_mountpoint "$1" "$2")

    echo "UUID=$uuid $mountpoint xfs rw,noatime,inode64,logbsize=256k  0 0" | ssh "$1" sudo tee -a /etc/fstab
}

check_fstab() {
    ssh "$1" grep -q '/var/lib/ceph/osd/ceph-' /etc/fstab
}

for host in ${host_list[@]}
do
    echo "HOST $host"
    check_fstab "$host"
    if [ $? -eq 0 ]; then
        echo "ceph disk has been in fstab already!!!"
        continue
    fi

    for device in ${device_list[@]}
    do
        generate_fstab_item "$host" "$device"
    done
done
