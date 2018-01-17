#!/bin/bash

source /opt/osdeploy/admin_openrc.sh
cinder_filename=cinder_list.log
nova_filename=nova_list.log
lvm_filename=lvm_list.log

host=$(hostname)
nova list --all --host "$host" | grep rds- | awk '{print $2}' > $nova_filename

sudo lvs | grep -v LV | awk '{print $1}' | grep -v "\-pool" | sed 's/volume-//g' > $lvm_filename

>$cinder_filename
while read nova_id
do
    cinder list --all | grep $nova_id | awk '{print $2}' >> $cinder_filename
done < $nova_filename

sort $cinder_filename -o $cinder_filename
sort $lvm_filename -o $lvm_filename
diff -u $lvm_filename $cinder_filename
