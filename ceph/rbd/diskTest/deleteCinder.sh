#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval $*
    [ $? -eq 0 ] || exit 1
}

tag=qrCloudin

for ID in $(cinder list --all | grep " $tag" | awk '{print $2}')
do
    doCommand cinder delete $ID
done
