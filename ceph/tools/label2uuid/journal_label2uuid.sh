#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

status_ok_except() {
    # Usage: status_ok_except "noout|noscrub|nodeep-scrub"
    local NUM=100 health_content monmap_content remain_content

    health_content=$(ceph -s | grep -A $NUM -w health -m 1)
    if [ $? -ne 0 ]; then
        echo "Cannot find health"
        return 0
    fi

    monmap_content=$(echo "$health_content" | grep -B $NUM -w monmap -m 1)
    if [ $? -ne 0 ]; then
        echo "Cannot find monmap"
        return 0
    fi

    remain_content=$(echo "$monmap_content" | sed -e '1d' -e '$d' | grep -Ev "$1")
    if [ ! -z "$remain_content" ]; then
        echo "Find other string"
        return 0
    fi
}

wait_for_complete() {
    while :
    do
        local stat=$(status_ok_except "noout|noscrub|nodeep-scrub|all OSDs are running jewel")
        if [ -z "$stat" ]; then
            break
        fi

        sleep 3
    done
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
        b|B|break|Break)
            echo "break"
            ;;
        *)
            ;;
    esac
}

find_device_uuid() {
    local uuid_root=$1 device=$2 result

    for path in $(find $uuid_root -maxdepth 1 -mindepth 1 -type l)
    do
        result=$(readlink -f $path)
        if [ "$result" == "$device" ]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

get_journal_device_label() {
    if [ ! -e "$1" ]; then
        printf "Journal %s doesn't exist" $1
        return 1
    fi

    if [ ! -L "$1" ]; then
        printf "Journal %s is not a link" $1
        return 2
    fi

    readlink $1
}

get_journal_device_uuid() {
    local uuid_resides=(/dev/disk/by-partuuid/ /dev/disk/by-id/)
    local journal_device=$(readlink -f $1) device_uuid

    for((i=0; i<${#uuid_resides[@]}; i++))
    do
        device_uuid=$(find_device_uuid ${uuid_resides[$i]} $journal_device)
        if [ $? -eq 0 ]; then
            echo "$device_uuid"
            return 0
        fi
    done

    return 1
}

replace_journal_link() {
    local osd_dir="$1" journal_path="$2" journal_device_uuid="$3"

    doCommand rm -f $journal_path
    doCommand ln -s $journal_device_uuid $journal_path
    doCommand chown -h ceph:ceph $journal_path
    doCommand "echo $(basename $journal_device_uuid) > $osd_dir/journal_uuid"
    doCommand chown ceph:ceph $osd_dir/journal_uuid
}

fix_journal_per_osd() {
        local osd_id="$1" osd_dir="$2" journal_path="$3" journal_device_uuid="$4" interactively="$5"

        if [ ! -z "$interactively" ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") OSD $osd_id: Link $journal_path to $journal_device_uuid => "
            printf "%26s Enter 'E' to exit, 'S' to skip, 'B' to break, any other key to continue: " ""
            case $(get_user_action) in
                exit)
                    exit 1
                    ;;
                skip)
                    continue
                    ;;
                break)
                    break
                    ;;
                *)
                    ;;
            esac
        fi

        doCommand stop ceph-osd id=$osd_id
        replace_journal_link $osd_dir $journal_path $journal_device_uuid
        doCommand start ceph-osd id=$osd_id
        wait_for_complete
}

fix_journal_per_host() {
    local osd_id journal_path journal_device_label journal_device_uuid

    if [ "$1" == "execute" ]; then
        doCommand ceph osd set noout
    fi

    for osd_dir in $(find /var/lib/ceph/osd -maxdepth 1 -mindepth 1 -type d | sort -t- -k2 -n)
    do
        osd_id=$(echo $osd_dir | cut -d '-' -f 2)
        journal_path=${osd_dir}/journal

        journal_device_label=$(get_journal_device_label $journal_path)
        if [ $? -ne 0 ]; then
            printf "OSD %3s: %s, cannot change to uuid\n" "$osd_id" "$journal_device_label"
            continue
        fi

        journal_device_uuid=$(get_journal_device_uuid $journal_path)
        if [ "$journal_device_label" == "$journal_device_uuid" ]; then
            printf "OSD %3s: Journal[%s] is OK\n" $osd_id $journal_device_label
            continue
        fi

        if [ "$1" == "execute" ]; then
            fix_journal_per_osd $osd_id $osd_dir $journal_path $journal_device_uuid $2
        else
            printf "OSD %3s: Link %s to %s\n" $osd_id $journal_path $journal_device_uuid
        fi
    done

    if [ "$1" == "execute" ]; then
        doCommand ceph osd unset noout
    fi
}

case $1 in
    execute|check)
        fix_journal_per_host $@
        ;;
    *)
        printf "Usage:\n\t%s <check | execute [interactively]>\n" "$0"
        ;;
esac
