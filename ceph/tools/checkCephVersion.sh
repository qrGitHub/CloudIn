#!/bin/bash

usage() {
    printf "Usage:\n\t$0 [version]|[-h]\n"
    exit $1
}

if [ ! "$BASH_VERSION" ]; then
    echo "Please use bash to run this script ($0)" 1>&2
    exit 1
fi

pkgList=("ceph-mds"
        "rest-bench"
        "rbd-fuse"
        "ceph-test"
        "radosgw"
        "ceph-fuse"
        "libcephfs-java"
        "librbd-dev"
        "librados-dev"
        "libradosstriper1"
        "ceph"
        "ceph-common"
        "python-ceph"
        "python-cephfs"
        "python-rbd"
        "python-rados"
        "librbd1"
        "librados2"
        "libcephfs-jni"
        "libcephfs1")

cephPkgName=ceph_*.deb
if [ $# -eq 0 ]; then
    if [ -f $cephPkgName ]; then
        expectVersion=$(ls $cephPkgName | awk -F"_" '{print $2}')
    else
        printf "Cannot find package version, you must specify one!!!\n"
        exit 1
    fi
elif [ $# -eq 1 ]; then
    if [ $1 == "-h" ]; then
        usage 0
    fi

    expectVersion=$1
else
    usage 1
fi

for host in $(grep "hosts =" /etc/ceph/ceph.conf | awk -F"=" '{print $2}' | awk -F"," '{for(i=1;i<=NF;i++) print $i}' | sort | uniq)
do
    unmatchList=""
    for pkg in ${pkgList[@]}
    do
        unmatch=$(ssh $host dpkg -l | grep "  $pkg " | awk '{if($3 !~ /^'"$expectVersion"'/) print $2":"$3}')
        if [ "$unmatch" != "" ]; then
            unmatchList="$unmatchList $unmatch"
        fi
    done

    if [ "$unmatchList" != "" ]; then
        echo "check $host Failed"
        echo "unmatch list:"
        echo -e "\t$unmatchList\n"
    else
        echo "check $host OK"
    fi
done
