#!/bin/bash

dpkgRemove() {
	echo "sudo dpkg -r $1"
	echo "========================"
	sudo dpkg -r $1
	[ $? -eq 0 ] || exit 1
	sudo dpkg --purge $1
}

dpkgRemove ceph-mds
dpkgRemove rest-bench
dpkgRemove rbd-fuse
dpkgRemove ceph-test
dpkgRemove radosgw
dpkgRemove ceph-fuse
dpkgRemove libcephfs-java
dpkgRemove libradosstriper1
dpkgRemove ceph
dpkgRemove ceph-common
dpkgRemove python-ceph
dpkgRemove python-cephfs
dpkgRemove python-rbd
dpkgRemove python-rados
dpkgRemove librbd1
dpkgRemove librados2
dpkgRemove libcephfs-jni
dpkgRemove libcephfs1
