#!/bin/bash

swapFile=/root/buildCeph/swap

sed -i -e '/'swap'/d' /etc/fstab
swapoff $swapFile
rm -f $swapFile
