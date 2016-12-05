#!/bin/bash

if [ $# -ne 1 ]; then
    printf "Usage:\n\tbash %s <trove name>\n" "$0"
    exit 1
fi

source /opt/osdeploy/admin_openrc.sh

name=$(echo "$1" | grep -Eo "rds-[^-]+")
if [ -z "$name" ]; then
    printf "%s is an illegal RDS name\n" "$1"
    exit 1
fi

for ID in $(trove list --all | grep "$name" | awk -F'|' '{print $2}')
do
    rds_name=$(trove show "$ID" | grep -w name | awk -F'|' '{print $3}' | sed s/[[:space:]]//g)
    if [ $? -ne 0 ]; then
        printf "get rds name for trove %s failed\n" "$ID"
        exit 1
    fi

    nova_id=$(trove show "$ID" | grep -w server_id | awk -F'|' '{print $3}' | sed s/[[:space:]]//g)
    if [ $? -ne 0 ]; then
        printf "get server id for trove %s failed\n" "$ID"
        exit 1
    fi

    host_name=$(nova show "$nova_id" | grep 'OS-EXT-SRV-ATTR:host' | awk -F'|' '{print $3}' | sed s/[[:space:]]//g)
    if [ $? -ne 0 ]; then
        printf "get host name for nova %s failed\n" "$nova_id"
        exit 1
    fi

    container_id=$(ssh "$host_name" "docker ps | grep $nova_id" | awk '{print $1}')
    if [ $? -ne 0 ]; then
        printf "get container id for nova %s failed\n" "$nova_id"
        exit 1
    fi

    printf "===================================================\n"
    printf "%12s : %s\n" "HOST NAME" "$host_name"
    printf "%12s : %s\n" "CONTAINER ID" "$container_id"
    printf "%12s : %s\n" "TROVE ID" "$ID"
    printf "%12s : %s\n" "RDS NAME" "$rds_name"
done
