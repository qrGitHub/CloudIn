#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

get_user_action() {
    read userChoice
    case $userChoice in
        e|E|exit|Exit)
            echo "exit"
            ;;
        s|S|skip|Skip)
            echo "skip"
            ;;
        y|Y|yes|Yes)
            echo "yes"
            ;;
        n|N|no|No)
            echo "no"
            ;;
        *)
            ;;
    esac
}

wait_for_complete() {
    local hint=${@:-Action}

    while :
    do
        echo -n "$(date +"%Y-%m-%d %H:%M:%S") $hint finished?(y/n): "
        case $(get_user_action) in
            yes)
                break
                ;;
            *)
                ;;
        esac
    done
}

adjust_osd_per_host() {
    local func="$1"
    local hint="$2"

    for osd_id in $(ls /var/lib/ceph/osd/ | cut -d '-' -f 2)
    do
        echo -n "$(date +"%Y-%m-%d %H:%M:%S") $hint $osd_id => "
        echo -n "Enter 'E' to exit, 'S' to skip, any other key to continue: "
        case $(get_user_action) in
            skip)
                continue
                ;;
            exit)
                exit 1
                ;;
            *)
                ;;
        esac
    
        "$func" "$osd_id"
        wait_for_complete "$hint $osd_id"
    done
}

out_per_osd() {
    doCommand ceph osd out "$1"
}

out_osds_per_host() {
    doCommand ceph osd set noout
    doCommand ceph osd set noscrub
    doCommand ceph osd set nodeep-scrub
    doCommand stop ceph-osd-all

    adjust_osd_per_host out_per_osd "Out osd"

    doCommand ceph osd unset nodeep-scrub
    doCommand ceph osd unset noscrub
    doCommand ceph osd unset noout
}

in_per_osd() {
    status ceph-osd id="$1" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        doCommand start ceph-osd id="$1"
    fi

    doCommand ceph osd in "$1"
}

in_osds_per_host() {
    adjust_osd_per_host in_per_osd "In osd"
}

case $1 in
    out)
        out_osds_per_host
        ;;
    in)
        in_osds_per_host
        ;;
    *)
        printf "Usage:\n\t%s <in|out>\n" "$0"
        ;;
esac
