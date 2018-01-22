#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

if [[ $# -ne 3 ]]; then
    printf "Usage:\n\tbash $0 <osd id> <osd device> <journal device>\n"
    printf "Example:\n\tbash $0 101 /dev/sdd1 /dev/disk/by-partuuid/1efb9ff2-5e48-4f96-af00-f7a71e86a4bb\n"
    exit 1
fi

osdID=$1
osdDevice=$2
osdJnl=$3
osdDir=/var/lib/ceph/osd/ceph-$osdID
jnlPath=$osdDir/journal

echo "Prepare file /etc/ceph/ceph.conf and scp it to other hosts"
doCommand ceph osd create
doCommand sudo mkdir -p $osdDir
doCommand sudo mkfs.xfs -f $osdDevice
doCommand sudo mount -o rw,noexec,nodev,noatime,nodiratime,attr2,discard,nobarrier,inode64,logbsize=256k,noquota $osdDevice $osdDir
doCommand sudo ceph-osd -i $osdID --mkfs --mkkey

doCommand rm $jnlPath
doCommand ln -s $osdJnl $jnlPath
doCommand ceph-osd --mkjournal -i $osdID

doCommand sudo ceph auth add osd.$osdID osd \'allow *\' mon \'allow rwx\' -i $osdDir/keyring
doCommand sudo touch $osdDir/upstart
doCommand sudo chown -R ceph:ceph $osdDir
doCommand sudo start ceph-osd id=$osdID
echo "Update the crush map"
