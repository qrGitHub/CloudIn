#!/bin/bash

instanceName="singleMysql"
mysqlDiskSize=2 # Unit: GB
flavorID=0

echo source /opt/osdeploy/admin_openrc.sh
echo trove create $instanceName $flavorID --size $mysqlDiskSize --datastore mysql --datastore_version 5.6

echo "trove show $instanceName | grep '^| id' | awk -F'|' '{print \$3}'"
echo trove create multiSlave $flavorID --size $mysqlDiskSize --replica_of \$instanceID --replica_count 2
