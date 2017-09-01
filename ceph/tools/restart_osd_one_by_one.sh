#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

status_ok_except() {
    # Usage: status_ok_except "noout|noscrub|nodeep-scrub"
    local NUM=100

    health_content=$(ceph -s | grep -A $NUM -w health -m 1)
    [ $? -eq 0 ] || return 1

    monmap_content=$(echo "$health_content" | grep -B $NUM -w monmap -m 1)
    [ $? -eq 0 ] || return 1

    remain_content=$(echo "$monmap_content" | sed -e '1d' -e '$d' | grep -Ev "$1")
    [ -z "$remain_content" ] || return 1
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

restart_osd() {
    doCommand restart ceph-osd id="$1"
}

restart_osds_per_host() {
    doCommand ceph osd set noout
    doCommand ceph osd set noscrub
    doCommand ceph osd set nodeep-scrub

    adjust_osd_per_host restart_osd "Restart osd"

    doCommand ceph osd unset nodeep-scrub
    doCommand ceph osd unset noscrub
    doCommand ceph osd unset noout
}

restart_osds_per_host
