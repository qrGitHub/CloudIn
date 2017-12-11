#!/bin/bash

homeDir=/var/lib/ceph

groupadd -g 64045 ceph
useradd -d $homeDir -u 64045 -g 64045 -c "Ceph storage service" -s /bin/false ceph
#mkdir $homeDir
#chown -R ceph:ceph $homeDir
