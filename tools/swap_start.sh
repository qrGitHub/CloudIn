#!/bin/bash

swapFile=/root/buildCeph/swap

# create swap file
dd if=/dev/zero of=$swapFile bs=1M count=2048
chmod 0600 $swapFile

# create swap
mkswap $swapFile

# start swap
swapon $swapFile

# auto mount
echo "$swapFile  swap  swap  sw  0  0"  >> /etc/fstab
