#!/bin/bash

dpkgRemove() {
	echo "sudo dpkg -r $1"
	echo "========================"
	sudo dpkg -r $1
	[ $? -eq 0 ] || exit 1
	sudo dpkg --purge $1
}

dpkgRemove rbd-fuse
dpkgRemove rbd-mirror
dpkgRemove ceph-fuse
dpkgRemove ceph-fs-common
dpkgRemove radosgw
dpkgRemove ceph-test
dpkgRemove ceph-mds
dpkgRemove ceph
dpkgRemove ceph-osd
dpkgRemove ceph-mon
dpkgRemove ceph-base
dpkgRemove ceph-common
dpkgRemove librgw2
dpkgRemove python-cephfs
dpkgRemove python-rbd
dpkgRemove python-rados
dpkgRemove librbd1
dpkgRemove libradosstriper1
dpkgRemove librados2
dpkgRemove libcephfs1
