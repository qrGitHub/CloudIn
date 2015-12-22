#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval $*
    [ $? -eq 0 ] || exit 1
}

pkgList=(cairocffi carbon whisper graphite-web django django-tagging)
installScript=installGraphiteWithoutInternet.sh


pipCacheDir=pip_cache
pipLogFile=pip.log

mkdir -p $pipCacheDir
>$pipLogFile

for ((i = ${#pkgList[@]}-1; i >= 0; i--))
do
    doCommand "sudo pip install -d $pipCacheDir ${pkgList[$i]} | tee -a $pipLogFile"
done

doCommand "grep ' Saved ' $pipLogFile | tac | awk -F'/' '{print \$NF}' | awk -F'-[0-9]' '{print \"sudo pip install --no-index -f '$pipCacheDir' \"\$1}' > $installScript"
doCommand rm -f $pipLogFile
