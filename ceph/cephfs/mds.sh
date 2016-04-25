#!/bin/bash

usage() {
    printf "Usage:\n\tbash $0 --add | --remove [--debug]\nExample:\n"
    printf "\tbash $0 --remove\tremove the metadata server on this machine\n"
    printf "\tbash $0 --add\tadd a metadata server on this machine\n"
    exit $1
}

EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

doCommand() {
    echo "^_^ doCommand: $*"
    if [ ! $debugFlag ]; then
        eval $*
    fi
}

addMDS() {
    #ceph-deploy --overwrite-conf mds create <hostname> [<hostname>...]
    doCommand sudo mkdir -p $mdsDir
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Create directory $mdsDir failed!"
        return $ret
    fi

    doCommand "sudo ceph auth get-or-create mds.$1 mon 'allow rwx' osd 'allow *' mds 'allow *' -o ${mdsDir}keyring"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Create keyring ${mdsDir}keyring failed!"
        return $ret
    fi

    doCommand sudo initctl emit ceph-mds cluster=ceph id=$1
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "start mds daemon(id=$1) failed!"
        return $ret
    fi

    # start mds daemon when host restart
    doCommand sudo touch ${mdsDir}done ${mdsDir}upstart
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "touch 'done' and 'upstart' file for mds failed!"
        return $ret
    fi

    echo "Update ceph.conf refer to confForMDS"
}

removeMDS() {
    doCommand sudo initctl stop ceph-mds id=$1
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "stop mds daemon(id=$1) failed!"
        return $ret
    fi

    doCommand sudo ceph auth del mds.$1
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "stop mds daemon(id=$1) failed!"
        return $ret
    fi

    doCommand sudo rm -rf $mdsDir
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "remove directory $mdsDir failed!"
        return $ret
    fi
}

TEMP=`getopt -o h --longoptions add,remove,debug -n "$0" -- "$@"`
if [ $? -ne 0 ]; then echo "Terminating..." >&2; exit 1; fi

eval set -- "$TEMP"
while true
do
    case "$1" in
        -h)
            helpFlag=1
            shift
            ;;
        --add)
            addFlag=1
            shift
            ;;
        --remove)
            removeFlag=1
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

if [[ $addFlag && $removeFlag ]]; then
    EXIT "Option --add and --remove are alternative"
fi

if [[ ! $addFlag && ! $removeFlag ]]; then
    EXIT "Option --add or --remove is missing"
fi

if [ $# -ne 0 ]; then
    EXIT "Parameter '$*' is not needed!"
fi
# Process arguments end
#=============================================================================>

mdsID=$(hostname)
mdsDir="/var/lib/ceph/mds/ceph-$mdsID/"

if [ $removeFlag ]; then
    removeMDS $mdsID
else
    addMDS $mdsID
fi
