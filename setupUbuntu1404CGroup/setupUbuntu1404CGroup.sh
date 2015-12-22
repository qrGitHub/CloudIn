#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval $*
    [[ $? -eq 0 ]] || exit 1
}

getLocalOsdIds() {
    osdIDs=($(ps aux | grep "ceph-osd .*-i" | grep -v grep | awk -F'-i' '{print $2}' | awk '{print $1}'))
}

getLocalMonId() {
    monID=$(ps aux | grep "ceph-mon .*-i" | grep -v grep | awk -F'-i' '{print $2}' | awk '{print $1}')
}

restartLocalOsdAll() {
    getLocalOsdIds

    for id in ${osdIDs[@]}
    do
        doCommand "restart ceph-osd id=$id"
    done
}

restartLocalMon() {
    getLocalMonId

    if [[ -n $monID ]]; then
        doCommand "restart ceph-mon id=$monID"
    fi
}

installCGroup() {
    doCommand sudo apt-get install -y cgroup-bin
}

restartCGroup() {
    doCommand service cgroup-lite restart

    # If /sys/fs/cgroup/cpu is not mounted, start cgroup fail
    for subSysName in `sed -e '1d;s/\([^\t]\)\t.*$/\1/' /proc/cgroups`; do
        mountpoint -q /sys/fs/cgroup/$subSysName
        if [[ $? -ne 0 ]]; then
            echo "/sys/fs/cgroup/$subSysName is not mounted, perhaps start service cgroup-lite failed"
            exit 1
        fi
    done
}

checkCgredService() {
    doCommand "ps aux | grep cgrulesengd | grep -v grep > /dev/null"
}

checkTasksFileOfCgroup() {
    local tasksIdsFile=.tasksIds.log
    local cmdIdsFile=.cmdIds.log

    for line in $(grep '^[^#]*{$' /etc/cgconfig.conf | awk '{if ($1 ~ /^group$/) { group = $2 } else { print $1"#"group}}')
    do
        local subSysName=$(echo ${line%#*})
        local groupName=$(echo ${line#*#})

        # get ids in cgroup tasks
        local taskFilePath=/sys/fs/cgroup/$subSysName/$groupName/tasks
        cat $taskFilePath | sort -n > $tasksIdsFile

        # get ids of command
        local cmd=$(grep '^[^#].*'$subSysName'.*'$groupName'$' /etc/cgrules.conf | awk '{print $1}' | awk -F':' '{print $2}')
        ps -eLf | grep " $cmd " | grep -v grep | awk '{print $4}' | sort -n > $cmdIdsFile

        diff -u $tasksIdsFile $cmdIdsFile > /dev/null
        if [[ $? -ne 0 ]]; then
            echo "IDs of command '$cmd' are different with that in tasks, the differences are:"
            diff -u $tasksIdsFile $cmdIdsFile
        else
            echo "check tasks file '$taskFilePath' success"
        fi
    done
}

setupCgConfigConfForUbuntu1404() {
    # create /etc/cgconfig.conf and /etc/cgrules.conf
    doCommand cp ./cgconfig.conf /etc/
    doCommand cp ./cgrules.conf /etc/

    # invoke /etc/cgconfig.conf in /etc/init/cgroup-lite.conf
    doCommand "patch -p0 /etc/init/cgroup-lite.conf < cgroup-lite.conf.diff"

    # create /etc/init/cgred.conf
    doCommand cp ./cgred.conf /etc/init/

    restartCGroup
    checkCgredService
}

installCGroup
setupCgConfigConfForUbuntu1404
#restartLocalOsdAll
#restartLocalMon
#sleep 60
#checkTasksFileOfCgroup
