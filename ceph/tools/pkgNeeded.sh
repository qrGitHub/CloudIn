#!/bin/bash

if [ $# -eq 0 ]; then
    checkPkg=1
else
    checkPkg=0
fi

pkgList=(autoconf automake autotools-dev pkg-config libtool libboost-dev libedit-dev libexpat1-dev libfcgi-dev libfuse-dev g++ gcc libsnappy-dev libleveldb-dev uuid-dev libblkid-dev libudev-dev libkeyutils-dev libcrypto++-dev libgoogle-perftools-dev libatomic-ops-dev libaio-dev xfslibs-dev libboost-thread-dev libboost-program-options-dev make debhelper libjemalloc-dev)

for pkg in ${pkgList[@]}
do
    dpkg -l | grep " $pkg" > /dev/null
    if [ $? -eq 0 ]; then
        continue;
    fi

	if [ $checkPkg -eq 1 ]; then
		echo $pkg
		continue
	fi

    cmd="apt-get install -y $pkg"
    echo "$cmd"
    $cmd
	if [ $? -ne 0 ]; then
	    exit 1
	fi
done
