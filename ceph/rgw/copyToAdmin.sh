#!/bin/bash

local_path=/Users/zhangbingyin/Documents/terminal/github/CloudIn/ceph/rgw/
case $1 in
    2)
        remote_host=root@123.59.214.231
        shift ;;
    3)
        remote_host=root@123.59.184.239
        shift ;;
    *)
        printf "Usage:\n\t%s <2|3> [-r]\n" "$0"
        exit 1
esac

remote_dir=/root/rgw/
remote_path=${remote_host}:${remote_dir}

if [ $# -eq 0 ]; then
    rsync -avz --progress --exclude-from .excludes.list -e 'ssh -p 10002' $local_path $remote_path
elif [ "$1" = "-r" ]; then
    rsync -avz --progress --exclude-from .excludes.list -e 'ssh -p 10002' $remote_path $local_path
else
    printf "Usage:\n\t%s <2|3> [-r]\n" "$0"
    exit 1
fi
