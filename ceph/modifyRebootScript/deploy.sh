#!/bin/bash

doCommand() {
    echo "^_^ $FUNCNAME: $*"
    eval "$@"
    [ $? -eq 0 ] || exit 1
}

usage() {
    printf "Usage:\n\t$0 [BeginHost]|[-h]|[-l]\n"
    exit $1
}

callerScript=/opt/startshell/init.bash
calleeScript=optimizeCephPerformance.sh
calleeDir=/usr/local/bin/

workDir=$(pwd)
list=0

if [ ! "$BASH_VERSION" ]; then
    echo "Please use bash to run this script ($0)" 1>&2
    exit 1
fi

if [ $# -eq 0 ]; then
    startDeploy=1
    beginHost=""
elif [ $# -eq 1 ]; then
    if [ $1 == "-h" ] || [ $1 == "--help" ]; then
        usage 0
    elif [ $1 == "-l" ] || [ $1 == "--list" ]; then
        list=1
    else
        startDeploy=0
        beginHost=$1
    fi
else
    usage 1
fi

for host in $(grep "hosts =" /etc/ceph/ceph.conf | awk -F"=" '{print $2}' | awk -F"," '{for(i=1;i<=NF;i++) print $i}' | sort | uniq)
do
    # Just list the host name
    if [ $list -eq 1 ]; then
        echo $host
        continue
    fi

    if [ "$host" == "$beginHost" ]; then
        startDeploy=1
    fi

    # Start or not
    if [ $startDeploy -ne 1 ]; then
        continue
    fi

    if [ "$host" == `hostname` ]; then
        doCommand sudo cp $calleeScript $calleeDir
        doCommand "sudo sed -i '\$a\\bash $calleeDir$calleeScript' $callerScript"
    else
        doCommand ssh $host mkdir -p $workDir
        doCommand scp $calleeScript openstack@$host:$workDir
        doCommand "ssh $host \"cd $workDir && sudo cp $calleeScript $calleeDir\""
        doCommand "ssh $host \"sudo sed -i '\\\$a\\bash $calleeDir$calleeScript' $callerScript\""
    fi
done
