#!/bin/bash

# Name of the new server
serverName=cephAdmin
# Name of snapshot
snapShotName="cephNodeImage"

source ./openstackLib.sh
setupOpenstackEnvironment

doCommand nova image-create $serverName $snapShotName
waitUntilActive "nova image-list | grep \" $snapShotName \" | awk '{print \$6}'"
