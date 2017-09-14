#!/bin/bash

bash purgeCluster.sh ceph21 ceph22 ceph23
if [ $? -ne 0 ]; then
    printf "purge Cluster failed\n"
    exit 1
fi

bash installCluster.sh ceph21 ceph22 ceph23
if [ $? -ne 0 ]; then
    printf "install packages failed\n"
    exit 1
fi

rm -rf ceph.*
ceph-deploy new ceph21 ceph22 ceph23
sed -i 's/cephx/none/g' ceph.conf
sed -i '2,$s/^/    /g' ceph.conf
sed -e '1d' deploy.conf >> ceph.conf
ceph-deploy --overwrite-conf mon create-initial
ceph-deploy --overwrite-conf osd create --zap-disk ceph21:/dev/vdb ceph21:/dev/vdc ceph22:/dev/vdb ceph22:/dev/vdc ceph23:/dev/vdb ceph23:/dev/vdc
ceph-deploy --overwrite-conf admin ceph21 ceph22 ceph23
ceph-deploy --overwrite-conf config push ceph21 ceph22 ceph23
