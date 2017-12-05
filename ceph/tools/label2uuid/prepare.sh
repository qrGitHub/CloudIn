#ceph osd set noout
#stop ceph-osd id=0
#rm -f /var/lib/ceph/osd/ceph-0/journal
#ln -s /dev/vdb2 /var/lib/ceph/osd/ceph-0/journal
#start ceph-osd id=0
#ceph osd unset noout

ceph osd set noout
stop ceph-osd id=1
rm -f /var/lib/ceph/osd/ceph-1/journal
ln -s /dev/vdc2 /var/lib/ceph/osd/ceph-1/journal
start ceph-osd id=1
ceph osd unset noout
