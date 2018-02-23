#!/bin/bash
set -e

if [ $# -eq 1 ]; then
    dir=$1
else
    dir=/dev/disk/by-id
fi

for file in $(ls $dir)
do
    path=$dir/$file
    orig_file=$(readlink -f $path)
    printf "%-10s %s\n" $orig_file $path
done
