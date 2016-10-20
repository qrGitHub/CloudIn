#!/bin/bash

if [ $# -ne 3 ]; then
    printf "Usage:\n\tbash %s <pool name> <from> <to>\n" "$0"
    exit 1
else
    pool_name=$1
    from=$2
    to=$3
fi

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$@"
    [ $? -eq 0 ] || exit 1
}

check_status() {
    ceph health | grep -w 'peering\|stale\|activating\|creating\|down' > /dev/null
    return $?
}

set_osd_status() {
    for flag in "$@"
    do
        doCommand ceph osd set "$flag"
    done
}

unset_osd_status() {
    for flag in "$@"
    do
        doCommand ceph osd unset "$flag"
    done
}

enable_scrub() {
    unset_osd_status nodeep-scrub noscrub
}

disable_scrub() {
    set_osd_status noscrub nodeep-scrub
}

set_maintenance_mode() {
    set_osd_status norecover nobackfill nodown noout
}

unset_maintenance_mode() {
    unset_osd_status noout nodown nobackfill norecover
}

disable_scrub
set_maintenance_mode

while [ "$from" -lt "$to" ]
do
    if [ $((to - from)) -gt 256 ]; then
        let "from += 256"
        let "from -= from % 256"
    else
        from=$to
    fi

    while sleep 10
    do
        check_status
        if [ $? -ne 0 ]
        then
            doCommand ceph osd pool set "$pool_name" pg_num "$from"
            echo "wait 60s for the cluster to create and peer the new pgs"
            sleep 60
            break
        fi
    done

    while sleep 10
    do
        check_status
        if [ $? -ne 0 ]
        then
            doCommand ceph osd pool set "$pool_name" pgp_num "$from"
            echo "wait 60s for the cluster to create and peer(pgp)"
            sleep 60
            break
        fi
    done
done

unset_maintenance_mode
enable_scrub

#First, create a function to check for any pg states that you don't want to continue if any pgs are in them (better than duplicating code).
#Second, set the flags so your cluster doesn't die when you do this.
#Third, set your numbers of current PGs and the desired PGs for the while loop. As you'll found, increasing by 256 is a good number. More than that and you'll run into issues of your cluster curling into a fetal position and crying. This will loop through increasing your pg_num, wait until everything is settled, then increase your pgp_num. The seemingly excessive sleeps are to help the cluster be able to resolve blocked requests that will still happen during this.
#Lastly unset the flags to let the cluster start moving the data around.
