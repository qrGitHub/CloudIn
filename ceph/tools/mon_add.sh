#!/bin/bash

usage() {
    printf "Usage:\n\tbash %s --id <mon id> --ip <mon ip> [--debug]\n" "$0"
    printf "Example:\n\tbash %s --id ceph13 --ip 172.16.1.9\n" "$0"
    exit $1
}

EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "%s\n" "$1"
    exit 1
}

doCommand() {
    echo "^_^ doCommand: $@"
    if [ ! $debug_flag ]; then
        eval "$@"
        [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1
    fi
}

conf_file="/etc/ceph/ceph.conf"
mon_dir="/var/lib/ceph/mon"
map_file="/tmp/monmap"

TEMP=`getopt -o h --longoptions id:,ip:,debug -n "$0" -- "$@"`
if [ $? -ne 0 ]; then echo "Terminating..." >&2; exit 1; fi

eval set -- "$TEMP"
while true
do
    case "$1" in
        -h)
            help_flag=1
            shift
            ;;
        --id)
            mon_id=$2
            shift 2
            ;;
        --ip)
            mon_ip=$2
            shift 2
            ;;
        --debug)
            debug_flag=1
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

if [ $help_flag ]; then
    usage 0
fi

if [[ ! $mon_id ]]; then
    EXIT "Option --mon_id is needed"
fi

if [[ ! $mon_ip ]]; then
    EXIT "Option --mon_ip is needed"
fi

if [ $# -ne 0 ]; then
    EXIT "Parameter '$*' is not needed!"
fi

add_monitor() {
    # Create the default directory on the machine that will host the new monitor.
    doCommand mkdir -p ${mon_dir}/ceph-"$mon_id"
    
    # Retrieve the monitor map
    doCommand ceph mon getmap -o "$map_file"
    
    # Prepare the monitor’s data directory created in the first step.
    #mon_keyring="/tmp/monkeyring"                                                          # 如开启cephx
    #doCommand ceph auth get mon. -o "$mon_keyring"                                         # 如开启cephx
    #doCommand ceph-mon -i "$mon_id" --mkfs --monmap "$map_file" --keyring "$mon_keyring"   # 如开启cephx
    doCommand ceph-mon -i "$mon_id" --mkfs --monmap "$map_file"                             # 未开启cephx
    doCommand chown -R ceph:ceph $mon_dir
    
    # Start the new monitor and it will automatically join the cluster.
    # ceph-mon -i "$mon_id" --public-addr "$mon_ip" (without upstart)
    doCommand sed -i "'\$a\[mon.$mon_id]' $conf_file"
    doCommand sed -i "'\$a\    public_addr = ${mon_ip}' $conf_file"
    doCommand start ceph-mon id=$mon_id
    doCommand sed -i "'\$d' $conf_file"
    doCommand sed -i "'\$d' $conf_file"
}

add_monitor
