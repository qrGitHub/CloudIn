#!/bin/bash

#troveName=$(echo "$1" | grep -Eo "rds-[^-]+")
troveName=$1
if [ -z "$troveName" ]; then
    printf "%s is an illegal RDS name\n" "$1"
    exit 1
fi

source /opt/osdeploy/admin_openrc.sh

for item in $(trove list --all | grep "$troveName" | awk '{print $2}')
do
    mysql -uopenstack -pb1526b0c -h10.10.2.205 -e "update trove.instances set task_id='81' where id='$item';"
done
# mysql -uopenstack -pb1526b0c -h10.10.2.205 -e "update trove.instances set virtual_ip_vrid=NULL where id='$item'"
