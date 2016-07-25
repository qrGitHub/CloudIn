#!/bin/bash
version=10.2.0

dpkgInstall() {
	echo "sudo dpkg -i $1"
	echo "========================"
	sudo dpkg -i $1
	[ $? -eq 0 ] || exit 1
}

dpkgInstall libcephfs1_$version-1_amd64.deb
dpkgInstall librados2_$version-1_amd64.deb
dpkgInstall libradosstriper1_$version-1_amd64.deb
dpkgInstall librbd1_$version-1_amd64.deb
dpkgInstall python-rados_$version-1_amd64.deb
dpkgInstall python-rbd_$version-1_amd64.deb
dpkgInstall python-cephfs_$version-1_amd64.deb
dpkgInstall librgw2_$version-1_amd64.deb
dpkgInstall ceph-common_$version-1_amd64.deb
dpkgInstall ceph-base_$version-1_amd64.deb
dpkgInstall ceph-mon_$version-1_amd64.deb
dpkgInstall ceph-osd_$version-1_amd64.deb
dpkgInstall ceph_$version-1_amd64.deb
dpkgInstall ceph-mds_$version-1_amd64.deb
dpkgInstall ceph-test_$version-1_amd64.deb
dpkgInstall radosgw_$version-1_amd64.deb
dpkgInstall ceph-fs-common_$version-1_amd64.deb
dpkgInstall ceph-fuse_$version-1_amd64.deb
