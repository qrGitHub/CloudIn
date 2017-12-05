#!/bin/bash

. common.sh

for osd_id in $(ls /var/lib/ceph/osd/ | cut -d '-' -f 2)
do
    doCommand bash restart_osd.sh $osd_id
done
