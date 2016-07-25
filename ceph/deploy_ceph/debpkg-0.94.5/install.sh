#!/bin/bash
version=0.94.5

dpkgInstall() {
	echo "sudo dpkg -i $1"
	echo "========================"
	sudo dpkg -i $1
	[ $? -eq 0 ] || exit 1
}

dpkgInstall libcephfs1_$version-1_amd64.deb
dpkgInstall libcephfs-jni_$version-1_amd64.deb
dpkgInstall librados2_$version-1_amd64.deb
dpkgInstall librbd1_$version-1_amd64.deb
dpkgInstall python-rados_$version-1_amd64.deb
dpkgInstall python-rbd_$version-1_amd64.deb
dpkgInstall python-cephfs_$version-1_amd64.deb
dpkgInstall python-ceph_$version-1_amd64.deb
dpkgInstall ceph-common_$version-1_amd64.deb
dpkgInstall ceph_$version-1_amd64.deb
dpkgInstall libradosstriper1_$version-1_amd64.deb
dpkgInstall libcephfs-java_$version-1_all.deb
dpkgInstall ceph-fuse_$version-1_amd64.deb
dpkgInstall radosgw_$version-1_amd64.deb
dpkgInstall ceph-test_$version-1_amd64.deb
dpkgInstall rbd-fuse_$version-1_amd64.deb
dpkgInstall rest-bench_$version-1_amd64.deb 
dpkgInstall ceph-mds_$version-1_amd64.deb
