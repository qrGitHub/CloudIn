#!/bin/bash
set -e

host_name=$(hostname)

ceph-mon --cluster=ceph -i $host_name --setuser ceph --setgroup ceph
ceph-mgr --cluster=ceph -i $host_name --setuser ceph --setgroup ceph

mount -o rw,nodev,noexec,noatime,nodiratime,attr2,discard,nobarrier,inode64,logbsize=256k,noquota UUID=0f25f020-1f3a-4307-90c8-8e086259e227 /var/lib/ceph/osd/ceph-0/
mount -o rw,nodev,noexec,noatime,nodiratime,attr2,discard,nobarrier,inode64,logbsize=256k,noquota UUID=c8f162b3-872d-43d1-8f1b-80780633b40e /var/lib/ceph/osd/ceph-1/
mount -o rw,nodev,noexec,noatime,nodiratime,attr2,discard,nobarrier,inode64,logbsize=256k,noquota UUID=93f5470b-6d98-480a-82ec-368b00954c58 /var/lib/ceph/osd/ceph-2/
ceph-osd --cluster=ceph -i 0 --setuser ceph --setgroup ceph
ceph-osd --cluster=ceph -i 1 --setuser ceph --setgroup ceph
ceph-osd --cluster=ceph -i 2 --setuser ceph --setgroup ceph

radosgw --cluster=ceph --id rgw.$host_name --setuser ceph --setgroup ceph
