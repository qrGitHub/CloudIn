#!/bin/bash

. common-functions

for host in $@
do
    doCommand ceph-deploy purge $host
    doCommand ceph-deploy purgedata $host
    doCommand ./uninstallCluster.sh $host
done
