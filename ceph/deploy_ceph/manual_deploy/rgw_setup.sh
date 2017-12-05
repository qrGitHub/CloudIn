#!/bin/bash
set -e

create_admin_user() {
    radosgw-admin user create --uid=admin --display-name=admin --access-key="51BH4DAYS1LT2JBPVQ6D" --secret="nGF25LzdvFcHyV1zhpSKA4DDRaiJqT5hLVmLie4z"
    radosgw-admin caps add --uid=admin --caps="users=read,write; usage=read,write; buckets=read,write"
}

bash rgw_deploy.sh 
bash rgwPoolCreate.sh debug

radosgw-admin realm create --rgw-realm=gold --default
radosgw-admin zonegroup create --rgw-zonegroup=cloudin --endpoints=http://172.16.1.7:7480 --rgw-realm=gold --master --default
radosgw-admin zone create --rgw-zone=debug --rgw-zonegroup=cloudin --endpoints=http://172.16.1.7:7480 --master --default
radosgw-admin user create --uid="synchronization-user" --display-name="Synchronization User" --system
radosgw-admin zone modify --rgw-zone=debug --access-key=09H4D4XIZY4A57KMG3K6 --secret=nW7ZahTiidchcTJqNExgz3wqEFUqASjCsvJcTJE0
radosgw-admin user create --uid="cloudInS3User" --display-name="First User" --access-key="9I8980NI0DE7GMBHR4AL" --secret="CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2"
create_admin_user

radosgw --cluster="${cluster:-ceph}" --id rgw.$(hostname) --setuser ceph --setgroup ceph
