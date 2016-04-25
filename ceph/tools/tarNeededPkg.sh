#!/bin/bash

version=$(ls ceph_*.deb | awk -F"_" '{print $2}')
tarName=ceph_${version}_debs.tgz
pkgDir=./

cd $pkgDir

neededPkgList=$(ls *.deb | grep -v "dbg_")
tar czf $tarName $neededPkgList

cd - >/dev/null
