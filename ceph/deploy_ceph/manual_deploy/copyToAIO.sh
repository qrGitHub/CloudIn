#!/bin/bash

local_path=$(pwd)/
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

base_name=$(basename $local_path)
remote_dir=/tmp/${base_name}/
remote_path=${remote_host}:${remote_dir}
remoter_path=AIO:/root/buildCeph/tools/${base_name}/

if [ $# -eq 0 ]; then
    rsync -rlptDvz --progress --delete-excluded --exclude-from .excludes.list -e 'ssh -p 10002' $local_path $remote_path
    ssh -p 10002 $remote_host rsync -rlptDvz --progress $remote_dir $remoter_path
elif [ "$1" = "-r" ]; then
    ssh -p 10002 $remote_host rsync -rlptDvz --progress $remoter_path $remote_dir
    rsync -rlptDvz --progress --exclude-from .excludes.list -e 'ssh -p 10002' $remote_path $local_path
else
    printf "Usage:\n\t%s <2|3> [-r]\n" "$0"
    exit 1
fi
