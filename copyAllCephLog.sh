#!/bin/bash

EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [[ $? -eq 0 ]] || EXIT "run '$*' failed"
}

monLine=$(ceph -s | grep " mons at ")
[[ $? -eq 0 ]] || EXIT "Cannot find monitor list through 'ceph -s'"

logDir=ceph.log-$(date +%F-%H-%M-%S)
doCommand mkdir $logDir

for item in $(echo $monLine | awk -F'{' '{print $2}' | awk -F',' '{for (i=1; i <=NF; i++) {print $i}}')
do
    monName=$(echo ${item%=*})
    tmpDirPath=/tmp/$monName

    doCommand ssh $monName mkdir -p $tmpDirPath
    doCommand ssh $monName sudo cp /var/log/ceph/ceph.log* $tmpDirPath
    doCommand ssh $monName sudo chown openstack $tmpDirPath/*
    doCommand ssh $monName sudo chgrp openstack $tmpDirPath/*
    doCommand scp -r $monName:$tmpDirPath ./$logDir
done
