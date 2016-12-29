#!/bin/bash

doCommand() {
    echo "^_^ $FUNCNAME: $*"
    eval "$@"
    [[ $? -eq 0 ]] || { printf "run command $* failed!\n"; exit 1; }
}

rbd showmapped | sed '1d' | awk '{print $5}' | while read device
do
    df -lh | grep -wq ^$device
    if [ $? -eq 0 ]; then
        doCommand umount $device
    fi

    doCommand rbd unmap $device
done
