#!/bin/bash

# BJ-BGP03-001-001
rbd create mysqlDisk01 -p volumes --size 512000 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/mysqlDisk01
mkfs.ext4 /dev/rbd2
mount /dev/rbd2 /var/lib/mysql

# BJ-BGP03-002-001
rbd create mysqlDisk02 -p volumes --size 512000 --image-format 2 --stripe-unit 33554432 --stripe-count 1
rbd map volumes/mysqlDisk02
mkfs.ext4 /dev/rbd2
mount /dev/rbd2 /var/lib/mysql
