#!/bin/bash
set -x
set -e

radosgw-admin realm create --rgw-realm=yufeng --default
radosgw-admin zonegroup create --rgw-zonegroup=hk --rgw-realm=yufeng --master --default
radosgw-admin zone create --rgw-zone=hk1 --rgw-zonegroup=hk --master --default
radosgw-admin user create --uid="synchronization-user" --display-name="Synchronization User" --system

access_key=$(radosgw-admin user info --uid=synchronization-user | grep access_key | awk -F'"' '{print $4}')
secret_key=$(radosgw-admin user info --uid=synchronization-user | grep secret_key | awk -F'"' '{print $4}')
radosgw-admin zone modify --rgw-zone=hk1 --access-key=$access_key --secret=$secret_key
radosgw-admin period update --commit

radosgw-admin user create --uid=admin --display-name=admin
radosgw-admin caps add --uid=admin --caps="users=read,write; usage=read,write; buckets=read,write"

radosgw-admin user create --uid="rds_backup" --display-name="Used for RDS backup"
