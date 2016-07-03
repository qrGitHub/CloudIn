#!/bin/bash

for((i=141; i < 160; i++))
do
    if [ $i -eq 156 ]; then
        continue
    fi
    eval "ceph osd in $i"
done
