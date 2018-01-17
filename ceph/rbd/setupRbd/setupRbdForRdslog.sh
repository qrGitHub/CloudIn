#!/bin/bash

# BJ-BGP03-001-001
rbd create rdsLog01 -p volumes --size 51200 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/rdsLog01
mkfs.ext4 /dev/rbd0
mount /dev/rbd0 /var/log/rds

# BJ-BGP03-002-001
rbd create rdsLog02 -p volumes --size 51200 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/rdsLog02
mkfs.ext4 /dev/rbd0
mount /dev/rbd0 /var/log/rds
