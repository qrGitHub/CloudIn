#!/bin/bash
set -e

create_admin_user() {
    radosgw-admin user create --uid=admin --display-name=admin
    radosgw-admin caps add --uid=admin --caps="users=read,write; usage=read,write; buckets=read,write"
}

bash rgw_deploy.sh 
bash rgwPoolCreate.sh debug

radosgw-admin realm create --rgw-realm=gold --default
radosgw-admin zonegroup create --rgw-zonegroup=cloudin --endpoints=http://172.16.1.7:7480 --rgw-realm=gold --master --default
radosgw-admin zone create --rgw-zone=debug --rgw-zonegroup=cloudin --endpoints=http://172.16.1.7:7480 --master --default
radosgw-admin user create --uid="synchronization-user" --display-name="Synchronization User" --system

access_key=$(radosgw-admin user info --uid=synchronization-user | grep access_key | awk -F'"' '{print $4}')
secret_key=$(radosgw-admin user info --uid=synchronization-user | grep secret_key | awk -F'"' '{print $4}')
radosgw-admin zone modify --rgw-zone=debug --access-key=$access_key --secret=$secret_key
radosgw-admin user create --uid="cloudInS3User" --display-name="First User"
create_admin_user

radosgw --cluster="${cluster:-ceph}" --id rgw.$(hostname) --setuser ceph --setgroup ceph
