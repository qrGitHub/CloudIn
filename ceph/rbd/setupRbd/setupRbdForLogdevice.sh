#!/bin/bash

# BJ-BGP03-001-001
rbd create logDisk01 -p volumes --size 512000 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/logDisk01
mkfs.ext4 /dev/rbd3
mount /dev/rbd3 /var/log/cloud

# BJ-BGP03-002-001
rbd create logDisk02 -p volumes --size 512000 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/logDisk02
mkfs.ext4 /dev/rbd3
mount /dev/rbd3 /var/log/cloud
