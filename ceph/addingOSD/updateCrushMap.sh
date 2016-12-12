#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    #eval "$@"
    [[ $? -eq 0 ]] || exit 1
}

onlyRead=0
if [[ $# -eq 1 && $1 = "-r" ]]; then
    onlyRead=1
fi

decompiledFile=crushmap.txt 
compiledFile=crushmap.bin

doCommand ceph osd getcrushmap -o $compiledFile
doCommand crushtool -d $compiledFile -o $decompiledFile
[[ $onlyRead -eq 1 ]] || echo "Edit the crush map as you need, exit vim when you finish"
[[ $onlyRead -eq 1 ]] || sleep 2
doCommand vim $decompiledFile
[[ $onlyRead -eq 1 ]] || doCommand crushtool -c $decompiledFile -o $compiledFile
[[ $onlyRead -eq 1 ]] || doCommand ceph osd setcrushmap -i $compiledFile
