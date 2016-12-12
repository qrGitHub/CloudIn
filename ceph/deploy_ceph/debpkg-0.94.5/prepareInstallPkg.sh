#!/bin/bash
version=0.94.5
pkgName=debpkg-$version

doCommand() {
	echo "^_^ doCommand: $*"
	#eval "$@"
	[ $? -eq 0 ] || exit 1
}

doCommand mkdir -p $pkgName
doCommand cp libcephfs1_$version-1_amd64.deb $pkgName/
doCommand cp libcephfs-jni_$version-1_amd64.deb $pkgName/
doCommand cp librados2_$version-1_amd64.deb $pkgName/
doCommand cp librbd1_$version-1_amd64.deb $pkgName/
doCommand cp python-rados_$version-1_amd64.deb $pkgName/
doCommand cp python-rbd_$version-1_amd64.deb $pkgName/
doCommand cp python-cephfs_$version-1_amd64.deb $pkgName/
doCommand cp python-ceph_$version-1_amd64.deb $pkgName/
doCommand cp ceph-common_$version-1_amd64.deb $pkgName/
doCommand cp ceph_$version-1_amd64.deb $pkgName/
doCommand cp libradosstriper1_$version-1_amd64.deb $pkgName/
doCommand cp librados-dev_$version-1_amd64.deb $pkgName/
doCommand cp librbd-dev_$version-1_amd64.deb $pkgName/
doCommand cp libcephfs-java_$version-1_all.deb $pkgName/
doCommand cp ceph-fuse_$version-1_amd64.deb $pkgName/
doCommand cp radosgw_$version-1_amd64.deb $pkgName/
doCommand cp ceph-test_$version-1_amd64.deb $pkgName/
doCommand cp rbd-fuse_$version-1_amd64.deb $pkgName/
doCommand cp rest-bench_$version-1_amd64.deb $pkgName/ 
doCommand cp ceph-mds_$version-1_amd64.deb $pkgName/


doCommand cp /home/openstack/qr/debpkg/install.sh $pkgName/
doCommand cp /home/openstack/qr/debpkg/uninstall.sh $pkgName/
doCommand cp /home/openstack/qr/debpkg/prepare.sh $pkgName/
