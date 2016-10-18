#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    #eval $*
    [[ $? -eq 0 ]] || exit 1
}

if [[ $# -ne 3 ]]; then
    printf "Usage:\n\tbash $0 <osd id> <journal path> <journal device>\n"
    printf "Example:\n\tbash $0 3 /var/lib/ceph/osd/ceph-3/journal /dev/sdb5\n"
    exit 1
fi

osdID=$1
journalPath=$2
devicePath=$3

doCommand sudo stop ceph-osd id=$osdID
doCommand sudo ceph-osd --flush-journal -i $osdID
doCommand sudo rm -f $journalPath
doCommand ln -s $devicePath $journalPath
doCommand ceph-osd -i $osdID --mkjournal
doCommand start ceph-osd id=$osdID