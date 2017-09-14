set -e

dpkg -r python-ceph
dpkg -r ceph-fuse
dpkg -r python-cephfs
dpkg -r python-rados
dpkg -r python-rbd
dpkg -r libcephfs1
dpkg -r rbd-fuse
dpkg -r librbd1
dpkg -r librgw2
dpkg -r libradosstriper1
dpkg -r librados2
dpkg -l | grep 10.2.5 | awk '{print $2}' | xargs -n 1 dpkg --purge
