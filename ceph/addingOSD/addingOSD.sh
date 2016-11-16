#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    #eval $*
    [[ $? -eq 0 ]] || exit 1
}

getFullRatio() {
    line=$(ps -ef | grep "ceph-osd " | grep -v grep)
    if [[ $? -ne 0 ]]; then
        echo "Cannot find osd daemon"
        exit 1
    fi

    osdID=$(echo $line | head -n 1 | awk -F"-i" '{print $2}' | awk '{print $1}')
    if [[ -z $osdID ]]; then
        echo "osdID is null"
        exit 1
    elif ! [[ "$osdID" =~ ^[0-9]+$ ]]; then
        echo "osdID($osdID) is not a number"
        exit 1
    fi

    ceph daemon osd.$osdID config show | grep "full_ratio"
}

if [[ $# -ne 4 ]]; then
    printf "Usage:\n\tbash $0 <osd id> <osd device> <osd weight> <bucket>\n"
    printf "Example:\n\tbash $0 140 /dev/sdf1 3.640 \"root=volumes-1 host=BJ-BGP01-003-03\"\n"
    exit 1
fi

osdID=$1
osdDevice=$2
weight=$3
bucket=$4
osdDir=/var/lib/ceph/osd/ceph-$osdID

doCommand ceph osd create
doCommand sudo mkdir -p $osdDir
doCommand sudo mkfs.xfs $osdDevice
doCommand sudo mount -o rw,noatime,inode64,logbsize=256k,delaylog $osdDevice $osdDir
doCommand sudo ceph-osd -i $osdID --mkfs --mkkey
doCommand sudo ceph auth add osd.$osdID osd \'allow *\' mon \'allow rwx\' -i $osdDir/keyring
doCommand sudo ceph osd crush add $osdID $weight $bucket
doCommand sudo touch $osdDir/upstart

echo "Verify the crush map, update it if needed"
echo "Prepare file /etc/ceph/ceph.conf and scp it to other hosts"

echo -e "\nIf there are several OSDs to be added, DO NOT start their OSD deamons alone;"
echo "The following command should be running together in the last"
doCommand sudo start ceph-osd id=$osdID
