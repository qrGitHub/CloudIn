#! /bin/bash

osdID=$1
devName=`df | grep ceph-$osdID | awk '{print $1}' | awk -F [/] '{print $3}'`
uuid=`blkid | grep $devName | awk -F [\"] '{print $2}'`
echo "UUID=$uuid /var/lib/ceph/osd/ceph-$osdID xfs rw,noatime,inode64,logbsize=256k,delaylog 0 0" | tee -a /etc/fstab
