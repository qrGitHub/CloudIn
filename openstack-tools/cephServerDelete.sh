#!/bin/bash

# Name of the new server
serverName=cephNode4
# Volume count
volumeCount=2

if [ $# -eq 1 ]; then
    serverName=$1
fi

source ./openstackLib.sh
setupOpenstackEnvironment

for ((i = $volumeCount; i > 0; i--))
do
    volumeID=$(cinder list | grep " $serverName$i " | awk '{print $2}')
    [ $? -eq 0 ] || exit 1

    doCommand nova volume-detach $serverName $volumeID
    doCommand cinder delete $volumeID
done

doCommand nova delete $serverName
