sed -i 's/^exec /#exec /g' /etc/init/ceph-mon.conf
sed -i '/exec /aexec cgexec -g memory:ceph_mon/mon"$id" /usr/bin/ceph-mon --cluster="${cluster:-ceph}" -i "$id" -f' /etc/init/ceph-mon.conf
sed -i 's/^exec /#exec /g' /etc/init/ceph-osd.conf
sed -i '/exec /aexec cgexec -g memory:ceph_osd/osd"$id" /usr/bin/ceph-osd --cluster="${cluster:-ceph}" -i "$id" -f' /etc/init/ceph-osd.conf
