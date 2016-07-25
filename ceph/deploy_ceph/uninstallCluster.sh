#!/bin/bash

. common-functions

pkgDir=/root/debpkg

for host in $@
do
    doCommand "ssh $host \"cd $pkgDir && bash uninstall.sh\""
done
