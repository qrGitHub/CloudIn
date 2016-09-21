#!/bin/bash

pool_name=rbd
from=128
to=512

check_status(){
    ceph health | grep -w 'peering\|stale\|activating\|creating\|down' > /dev/null
    return $?
}

set_osd_status() {
    for flag in $*
    do
        ceph osd set $flag
    done
}

unset_osd_status() {
    for flag in $*
    do
        ceph osd unset $flag
    done
}

set_osd_status nobackfill norecover noout nodown

while [ $from -lt $to ]
do
    if [ $(($to - $from)) -gt 256 ]; then
        let "from += 256"
        let "reminder = from % 256"
        let "from -= reminder"
    else
        from=$to
    fi

    while sleep 10
    do
        check_status
        if [ $? -ne 0 ]
        then
            ceph osd pool set $pool_name pg_num $from
            sleep 60
            break
        fi
    done

    while sleep 10
    do
        check_status
        if [ $? -ne 0 ]
        then
            ceph osd pool set $pool_name pgp_num $from
            sleep 60
            break
        fi
    done
done

unset_osd_status nobackfill norecover noout nodown
