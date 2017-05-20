#!/bin/bash

# print a log and then exit
EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

usage() {
    printf "Usage:\n\tbash $0 --hostname remotehost --osdID 0 --sata /dev/sda --ssd /dev/sdb:sdz\n"
    printf "\tbash $0 --hostname localhost --osdID 156 --ssd \"/dev/sda:sdz /dev/sdb\"\n"
    printf "\tbash $0 --hostname BJ-BGP01-003-03 --osdID 140 --sata /dev/sdf:sdb1\n"
    printf "\tbash $0 -h\n"
    exit $1
}

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

pkgDir=/opt/osdeploy/deploy/src/ceph/openstack-ceph-debpkgs
installCephPkgs() {
    doCommand "ssh $hostname \"cd $pkgDir && bash prepare.sh\""
    doCommand "ssh $hostname \"cd $pkgDir && bash install.sh\""
}

clientDir=/var/run/ceph/ceph-client
prepareClientDir() {
    doCommand ssh $hostname sudo mkdir -p $clientDir
    doCommand ssh $hostname sudo chmod 777 $clientDir
}

verifyBash() {
    [ -n "$BASH_VERSION" ] || EXIT "Please use bash to run this script ($0)"
}

verifyBash

# ==============================================================
# Modify these configurations as you need
# Flags
prepareClientDirFlag=1
installCephPkgsFlag=0

# List all cluster host names here
clusterHosts=(
    BJ-BGP01-002-01
    BJ-BGP01-002-02
    BJ-BGP01-002-03
    BJ-BGP01-002-04
    BJ-BGP01-002-05
    BJ-BGP01-002-06
    BJ-BGP01-002-07
    BJ-BGP01-002-08
    BJ-BGP01-003-01
    BJ-BGP01-003-02
    BJ-BGP01-003-03
    BJ-BGP01-003-04
    BJ-BGP01-003-05
    BJ-BGP01-003-06
    BJ-BGP01-003-07
    BJ-BGP01-003-08
)
# ==============================================================

#hostname=BJ-BGP01-003-03
#sataDeviceList=(/dev/sdh:sdc1 /dev/sdi:sdc2 /dev/sdj:sdd1 /dev/sdk:sdd2 /dev/sdl:sdd3)
#ssdDeviceList=(/dev/sdb6:sdc3 /dev/sdc6:sdd5 /dev/sdd6:sdb3)
#sataDeviceList=(/dev/sdf:sdb1)
#sataDeviceList=(/dev/sdf:sdb1 /dev/sdg:sdb2 /dev/sdh:sdc1 /dev/sdi:sdc2 /dev/sdj:sdd1 /dev/sdk:sdd2 /dev/sdl:sdd3)
#hostname=BJ-BGP01-003-06
#sataDeviceList=(/dev/sdf:sdb1 /dev/sdg:sdb2 /dev/sdh:sdc1 /dev/sdi:sdc2 /dev/sdj:sdd1 /dev/sdk:sdd2 /dev/sdl:sdd3)
#ssdDeviceList=(/dev/sdb6:sdc3 /dev/sdc5:sdd5 /dev/sdd6:sdb3)

TEMP=`getopt -o h --longoptions hostname:,sata:,ssd:,osdID:,copy -n "$0" -- "$@"`
if [ $? -ne 0 ]; then echo "Terminating..." >&2; exit 1;fi

eval set -- "$TEMP"
while true
do
    case "$1" in
        -h)
            helpFlag=1
            shift
            ;;
        --copy)
            copy=1
            shift
            ;;
        --hostname)
            hostname=$2
            shift 2
            ;;
        --osdID)
            osdID=$2
            shift 2
            ;;
        --sata)
            sataDeviceList=($2)
            shift 2
            ;;
        --ssd)
            ssdDeviceList=($2)
            shift 2
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

if [ -z $hostname ]; then
    EXIT "Option --hostname is needed!"
fi

if [ -z $osdID ]; then
    EXIT "Option --osdID is needed!"
fi

if [ $# -ne 0 ]; then
    EXIT "Parameter '$*' is not needed!"
fi

if [ $installCephPkgsFlag -ne 0 ]; then
    installCephPkgs
fi

if [ $prepareClientDirFlag -ne 0 ]; then
    prepareClientDir
fi

for device in ${sataDeviceList[@]}
do
    doCommand ceph-deploy --overwrite-conf osd create $hostname:$device
    doCommand ceph osd out $osdID
    let "osdID++"
    sleep 3
done

for device in ${ssdDeviceList[@]}
do
    doCommand ceph-deploy --overwrite-conf osd create $hostname:$device
    doCommand ceph-deploy osd activate $hostname:$device
    doCommand ceph osd out $osdID
    let "osdID++"
    sleep 3
done

if [ -z $copy ]; then
    exit 0
fi

read -p \
"Copy /etc/ceph/volumes.keyring to $hostname:/etc/ceph/volumes.keyring
     /etc/ceph/cinder.keyring to $hostname:/etc/ceph/cinder.keyring
     /etc/ceph/images.keyring to $hostname:/etc/ceph/images.keyring
[y/n] " userChoice

case $userChoice in
    y|Y|yes|Yes)
        doCommand scp /etc/ceph/volumes.keyring $hostname:/etc/ceph/volumes.keyring
        doCommand scp /etc/ceph/cinder.keyring $hostname:/etc/ceph/cinder.keyring
        doCommand scp /etc/ceph/images.keyring $hostname:/etc/ceph/images.keyring
        ;;
    *)
        ;;
esac

read -p "Broadcast ./ceph.client.admin.keyring and ./ceph.conf to all ceph hosts?[y/n] " userChoice
case $userChoice in
    y|Y|yes|Yes)
        # copy 'ceph.client.admin.keyring' and 'ceph.conf' of the current directory to hosts
        doCommand ceph-deploy --overwrite-conf admin ${clusterHosts[@]}

        # copy 'ceph.conf' of the current directory to hosts
        #doCommand ceph-deploy --overwrite-conf config push ${clusterHosts[@]}
        ;;
    *)
        ;;
esac
