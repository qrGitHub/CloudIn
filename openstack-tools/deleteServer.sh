#!/bin/bash

serverName=testVM4

usage() {
    printf "Usage:\n\t$0 [serverName]|[-h]\n"
    exit $1
}

if [ $# -gt 1 ]; then
    usage 1
elif [ $# -eq 1 ]; then
    if [ "$1" == "-h" ]; then
        usage 0
    else
        serverName=$1
    fi
fi

source ./openstackLib.sh
setupOpenstackEnvironment

cmd="nova list | grep \" $serverName \""
echo "^_^ : $cmd"
line=$(eval $cmd)
if [ $? -ne 0 ]; then
    echo "VM $serverName doesn't exist"
    exit 0 
fi

floatingIP=$(echo $line | awk -F'|' '{print $7}' | awk -F'=' '{print $2}' | awk '{print $2}')
if [ "$floatingIP" != "" ]; then
    doCommand nova floating-ip-disassociate $serverName $floatingIP

    cmd="neutron floatingip-list | grep \"$floatingIP\" | awk '{print \$2}'"
    echo "^_^ : $cmd"
    floatingIpID=$(eval $cmd)
    doCommand neutron floatingip-delete $floatingIpID
fi

doCommand nova delete $serverName
