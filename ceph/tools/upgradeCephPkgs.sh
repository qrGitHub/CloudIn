#!/bin/bash

#homeDir=/home/openstack/qr
#pkgName=debpkg-0.94.5/
#workDir=$homeDir/$pkgName
#doCommand scp -r $pkgName openstack@$host:$homeDir

doCommand() {
    echo "^_^ $FUNCNAME: $*"
    eval $*
    [ $? -eq 0 ] || exit 1
}

usage() {
    printf "Usage:\n\t$0 [BeginHost]|[-h]|[-l]\n"
    exit $1
}

workDir=$(pwd)
list=0

if [ ! "$BASH_VERSION" ]; then
    echo "Please use bash to run this script ($0)" 1>&2
    exit 1
fi

if [ $# -eq 0 ]; then
    upgrading=1
    beginHost=""
elif [ $# -eq 1 ]; then
    if [ $1 == "-h" ] || [ $1 == "--help" ]; then
        usage 0
    elif [ $1 == "-l" ] || [ $1 == "--list" ]; then
        list=1
    else
        upgrading=0
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
        upgrading=1
    fi

    # Start upgrading or not
    if [ $upgrading -ne 1 ]; then
        continue
    fi

    if [ "$host" == `hostname` ]; then
        bash uninstall.sh
        doCommand bash prepare.sh
        doCommand bash install.sh
        doCommand sudo restart ceph-all
    else
        doCommand ssh $host mkdir -p $workDir
        doCommand scp -r . openstack@$host:$workDir
        ssh $host "cd $workDir && bash uninstall.sh"
        doCommand "ssh $host \"cd $workDir && bash prepare.sh\""
        doCommand "ssh $host \"cd $workDir && bash install.sh\""
        doCommand ssh $host sudo restart ceph-all
    fi
done
