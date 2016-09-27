#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval $*
    [[ $? -eq 0 ]] || exit 1
}

pool_name=rbd
image_name=rbd01
new_size=11264

doCommand rbd resize -p $pool_name --size $new_size $image_name

device=$(rbd showmapped | grep -E "$pool_name\s+$image_name" | awk '{print $NF}')
mount_path=$(mount | grep $device | awk '{print $3}')

doCommand umount $mount_path

doCommand e2fsck -f $device
doCommand resize2fs $device

doCommand mount $device $mount_path
