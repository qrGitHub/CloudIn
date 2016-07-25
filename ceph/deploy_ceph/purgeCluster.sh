#!/bin/bash

. common-functions

for host in $@
do
    doCommand ./uninstallCluster.sh $host
    doCommand ceph-deploy purge $host
    doCommand ceph-deploy purgedata $host
done
