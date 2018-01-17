#!/bin/bash

# BJ-BGP03-001-001
rbd create dockerDisk01 -p volumes --size 102400 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/dockerDisk01
mkfs.ext4 /dev/rbd1
mount /dev/rbd1 /var/lib/docker

# BJ-BGP03-002-001
rbd create dockerDisk02 -p volumes --size 102400 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/dockerDisk02
mkfs.ext4 /dev/rbd1
mount /dev/rbd1 /var/lib/docker
