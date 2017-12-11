#!/bin/bash

host_list=(ceph31 ceph32 ceph33)

. common-functions

#bash purgeCluster.sh ceph31 ceph32 ceph33
#if [ $? -ne 0 ]; then
#    printf "purge Cluster failed\n"
#    exit 1
#fi

for host in ${host_list[@]}
do
    doCommand "ssh $host apt-get install ceph ceph-common ceph-fs-common rbd-fuse radosgw python-ceph"
    doCommand "ssh $host chown ceph:ceph /dev/vdb1 /dev/vdb2 /dev/vdc1 /dev/vdc2"
    doCommand ssh $host sgdisk -g -t 1:45B0969E-9B03-4F30-B4C6-B4B80CEFF106 /dev/vdc
    doCommand ssh $host sgdisk -g -t 2:45B0969E-9B03-4F30-B4C6-B4B80CEFF106 /dev/vdc
    doCommand ssh $host sgdisk -g -t 1:4FBD7E29-9D25-41B8-AFD0-062C0CEFF05D /dev/vdb
    doCommand ssh $host sgdisk -g -t 2:4FBD7E29-9D25-41B8-AFD0-062C0CEFF05D /dev/vdb
done

rm -rf ceph.*
ceph-deploy new ceph31 ceph32 ceph33
sed -i 's/cephx/none/g' ceph.conf
sed -i '2,$s/^/    /g' ceph.conf
sed -e '1d' deploy.conf >> ceph.conf
ceph-deploy --overwrite-conf mon create-initial
ceph-deploy --overwrite-conf osd create ceph31:/dev/vdb1:vdc1 ceph31:/dev/vdb2:vdc2 ceph32:/dev/vdb1:vdc1 ceph32:/dev/vdb2:vdc2 ceph33:/dev/vdb1:vdc1 ceph33:/dev/vdb2:vdc2
ceph-deploy --overwrite-conf osd activate ceph31:/dev/vdb1:vdc1 ceph31:/dev/vdb2:vdc2 ceph32:/dev/vdb1:vdc1 ceph32:/dev/vdb2:vdc2 ceph33:/dev/vdb1:vdc1 ceph33:/dev/vdb2:vdc2
ceph-deploy --overwrite-conf admin ceph31 ceph32 ceph33
ceph-deploy --overwrite-conf config push ceph31 ceph32 ceph33
