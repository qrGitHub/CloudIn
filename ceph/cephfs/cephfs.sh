#!/bin/bash

usage() {
    printf "Example:\n"
    printf "\tbash $0 --create --metadataPoolName cephfs_metadata --dataPoolName cephfs_data --metadataPoolPgnum 32 --dataPoolPgnum 32\n"
    printf "\tbash $0 --remove --metadataPoolName cephfs_metadata --dataPoolName cephfs_data\n"
    printf "\tbash $0 --mount --mountPoint /cephfs/ --monitorIP 10.1.0.21\n"
    printf "\tbash $0 --umount --mountPoint /cephfs/\n"
    printf "Description:\n\tSometimes before removing ceph fs, we need to stop all mds daemons first\n"
    exit $1
}

EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

doCommand() {
    echo "^_^ doCommand: $*"
    if [ ! $debugFlag ]; then
        eval "$@"
    fi
}

createCephFS() {
    doCommand ceph osd pool create $dataPoolName $dataPoolPgnum
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Create pool $dataPoolName failed!"
        return $ret
    fi

    doCommand ceph osd pool create $metadataPoolName $metadataPoolPgnum
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Create pool $metadataPoolName failed!"
        return $ret
    fi

    doCommand ceph fs new cephfs $metadataPoolName $dataPoolName
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Create ceph fs failed!"
        return $ret
    fi

    # wait until the state of MDS become active
    while [ 1 ]
    do
        doCommand "ceph mds stat | grep ':active'"
        if [ $? -eq 0 ]; then
            break
        fi

        sleep 5
    done
}

refreshCephFs() {
    local metadataPoolID=$(ceph df | grep $metadataPoolName | awk '{print $2}')
    local dataPoolID=$(ceph df | grep $dataPoolName | awk '{print $2}')

    # Swap the position of metadata pool and data pool, we can also use other pools.
    doCommand ceph mds newfs $dataPoolID $metadataPoolID --yes-i-really-mean-it
}

removeCephFs() {
    # We need to refresh the ceph fs before removing it, or we cannot remove it.
    refreshCephFs
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Refresh ceph fs failed!"
        return $ret
    fi

    doCommand ceph fs rm cephfs --yes-i-really-mean-it
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Remove ceph fs failed!"
        return $ret
    fi

    doCommand ceph osd pool delete $metadataPoolName $metadataPoolName --yes-i-really-really-mean-it
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Delete pool $metadataPoolName failed!"
        return $ret
    fi

    doCommand ceph osd pool delete $dataPoolName $dataPoolName --yes-i-really-really-mean-it
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Delete pool $dataPoolName failed!"
        return $ret
    fi
}

mountCephFs() {
    doCommand sudo mkdir -p $mountPoint
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Create directory $mountPoint failed!"
        return $ret
    fi

    doCommand sudo mount -t ceph $monitorIP:6789:/ $mountPoint
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "mount ceph fs failed!"
        return $ret
    fi

    doCommand sudo chmod 777 $mountPoint
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Change mode of $mountPoint to 777 failed!"
        return $ret
    fi

    mountPoint=$(echo ${mountPoint//\//\\\/})
    doCommand "sudo sed -i '\$a\\$monitorIP:6789:\/ $mountPoint ceph noatime 0 2' /etc/fstab"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "add /etc/fstab item failed!"
        return $ret
    fi
}

umountCephFs() {
    doCommand sudo umount $mountPoint
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "umount ceph fs failed!"
        return $ret
    fi

    doCommand sudo rm -rf $mountPoint
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "remove directory $mountPoint failed!"
        return $ret
    fi

    mountPoint=$(echo ${mountPoint%\/})
    mountPoint=$(echo ${mountPoint//\//\\\/})
    doCommand "sudo sed -i '/:6789:\/[ \t][ \t]*$mountPoint\/\?[ \t]/d' /etc/fstab"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "remove /etc/fstab item failed!"
        return $ret
    fi
}

TEMP=`getopt -o h --longoptions create,metadataPoolName:,metadataPoolPgnum:,dataPoolName:,dataPoolPgnum:,mount,mountPoint:,monitorIP:,remove,umount,debug -n "$0" -- "$@"`
if [ $? -ne 0 ]; then echo "Terminating..." >&2; exit 1; fi

eval set -- "$TEMP"
while true
do
    case "$1" in
        -h)
            helpFlag=1
            shift
            ;;
        --create)
            createFlag=1
            shift
            ;;
        --metadataPoolName)
            metadataPoolName=$2
            shift 2
            ;;
        --dataPoolName)
            dataPoolName=$2
            shift 2
            ;;
        --metadataPoolPgnum)
            metadataPoolPgnum=$2
            shift 2
            ;;
        --dataPoolPgnum)
            dataPoolPgnum=$2
            shift 2
            ;;
        --remove)
            removeFlag=1
            shift
            ;;
        --mount)
            mountFlag=1
            shift
            ;;
        --mountPoint)
            mountPoint=$2
            shift 2
            ;;
        --monitorIP)
            monitorIP=$2
            shift 2
            ;;
        --umount)
            umountFlag=1
            shift
            ;;
        --debug)
            debugFlag=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
    esac
done

if [ $helpFlag ]; then
    usage 0
fi

if [[ $createFlag && $removeFlag ]]; then
    EXIT "Option --create and --remove are alternative"
fi

if [[ $mountFlag && $umountFlag ]]; then
    EXIT "Option --mount and --umount are alternative"
fi

if [[ $createFlag ]]; then
    if [[ ! $metadataPoolName ]]; then
        EXIT "Option --metadataPoolName is needed for --create"
    fi

    if [[ ! $dataPoolName ]]; then
        EXIT "Option --dataPoolName is needed for --create"
    fi

    if [[ ! $metadataPoolPgnum ]]; then
        EXIT "Option --metadataPoolPgnum is needed for --create"
    fi

    if [[ ! $dataPoolPgnum ]]; then
        EXIT "Option --dataPoolPgnum is needed for --create"
    fi
fi

if [[ $removeFlag ]]; then
    if [[ ! $metadataPoolName ]]; then
        EXIT "Option --metadataPoolName is needed for --remove"
    fi

    if [[ ! $dataPoolName ]]; then
        EXIT "Option --dataPoolName is needed for --remove"
    fi
fi

if [[ $mountFlag ]]; then
    if [[ ! $mountPoint ]]; then
        EXIT "Option --mountPoint is needed for --mount"
    fi

    if [[ ! $monitorIP ]]; then
        EXIT "Option --monitorIP is needed for --mount"
    fi
fi

if [[ $umountFlag ]]; then
    if [[ ! $mountPoint ]]; then
        EXIT "Option --mountPoint is needed for --umount"
    fi
fi

if [ $# -ne 0 ]; then
    EXIT "Parameter '$*' is not needed!"
fi
# Process arguments end
#=============================================================================>

if [ $createFlag ]; then
    createCephFS
fi

if [ $removeFlag ]; then
    removeCephFs
fi

if [ $mountFlag ]; then
    mountCephFs
fi

if [ $umountFlag ]; then
    umountCephFs
fi
