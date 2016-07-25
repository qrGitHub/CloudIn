#!/bin/bash

for host in $@
do
    ssh $host "sed -i 's/ubuntu/'$host'/' /etc/hosts"
    ssh $host "sed -i 's/ubuntu/'$host'/' /etc/hostname"
    ssh $host "reboot"
done
