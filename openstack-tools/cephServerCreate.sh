#!/bin/bash

# Name of the new server
serverName=cephNode1
# Name or ID of flavor 
flavor=c2m2d40
# Name or ID of image
imageName=cephNodeImage
netID=83c48071-7469-4dd5-b55d-0e286a86e102
# Volume size
volumeSize=100
# Volume count
volumeCount=2

if [ $# -eq 1 ]; then
    serverName=$1
fi

source ./openstackLib.sh
setupOpenstackEnvironment

imageID=$(nova image-list | grep "$imageName" | awk '{print $2}')

doCommand nova boot --flavor $flavor --image $imageID --security-groups default --nic net-id=$netID $serverName
waitUntilActive "nova list | grep \" $serverName \" | awk '{print \$6}'"

for ((i = 1; i <= $volumeCount; i++))
do
    doCommand cinder create --volume-type sata --name $serverName$i $volumeSize
    volumeID=$(cinder list | grep " $serverName$i " | awk '{print $2}')
    [ $? -eq 0 ] || exit 1

    doCommand nova volume-attach $serverName $volumeID
done
