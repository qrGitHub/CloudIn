#!/bin/bash

# Name of the new server
serverName=cephAdmin
# Name or ID of flavor 
flavor=c2m2d40
# Name or ID of image
image=205d94a6-6479-4673-a6d2-1e0e9f3531e8
netID=83c48071-7469-4dd5-b55d-0e286a86e102

source ./openstackLib.sh
setupOpenstackEnvironment

#doCommand nova boot --flavor $flavor --image $image --security-groups default --nic net-id=$netID $serverName --key_name testKey
doCommand nova boot --flavor $flavor --image $image --security-groups default --nic net-id=$netID $serverName
waitUntilActive "nova list | grep \" $serverName \" | awk '{print \$6}'"

nova set-password $serverName

cmd="neutron floatingip-create ext-net | grep ' floating_ip_address '"
echo "^_^ : $cmd"
line=$(eval $cmd)
[ $? -eq 0 ] || exit 1

floatingIP=$(echo $line | awk '{print $4}')
echo "Create floatingIP $floatingIP Success"

doCommand nova floating-ip-associate $serverName $floatingIP
