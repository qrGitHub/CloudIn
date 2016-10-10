#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    #eval $*
    [[ $? -eq 0 ]] || exit 1
}

if [[ $# -ne 3 ]]; then
    printf "Usage:\n\tbash $0 <osd id> <journal old path> <journal new path>\n"
    printf "Example:\n\tbash $0 3 /var/lib/ceph/osd/ceph-3/journal /tmp/journal\n"
    exit 1
fi

osdID=$1
journalOldPath=$2
journalNewPath=$3

doCommand sudo stop ceph-osd id=$osdID
doCommand sudo ceph-osd --flush-journal -i $osdID
sleep 2
doCommand sudo mv $journalOldPath $journalNewPath
doCommand sudo ln -s $journalNewPath $journalOldPath
sleep 3
doCommand start ceph-osd id=$osdID
