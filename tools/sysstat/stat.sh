#!/bin/bash

. common.sh

sys_filename="${2:+$2_}sysstat.dat"
sys_interval=5

pid_comm='/usr/bin/ceph-osd|/usr/bin/ceph-mon|/usr/bin/radosgw'
pid_filename="${2:+$2_}pidstat.dat"
pid_interval=5

comm2pid() {
    local pid_list=""

    for name in $(string2array "$1" "|")
    do
        for pid in $(pname2pid $name)
        do
            if [ -z "$pid_list" ]; then
                pid_list=$pid
            else
                pid_list=$pid_list,$pid
            fi
        done
    done

    echo "$pid_list"
}

start_background_pidstat() {
    local pid_list=$(comm2pid "$pid_comm")

    pidstat -urdh -p $pid_list $pid_interval > $pid_filename &
    echo $!
}

start_background_sysstat() {
    >$sys_filename
    sar -urdp -o $sys_filename $sys_interval >/dev/null 2>&1 &
    echo $!
}

stop_background_pidstat() {
    KILL $pidstat_pid SIGINT
}

stop_background_sysstat() {
    # LC_TIME=posix sar -u -f $sys_filename $sys_interval
    # LC_TIME=posix sar -r -f $sys_filename $sys_interval
    # LC_TIME=posix sar -dp -f $sys_filename $sys_interval

    KILL $sysstat_pid SIGINT
}

pid_list=".pid_list.txt"
if [ "$1" = "start" ]; then
    pidstat_pid=$(start_background_pidstat)
    sysstat_pid=$(start_background_sysstat)
    echo -e "${pidstat_pid}\n${sysstat_pid}" > $pid_list
elif [ "$1" = "stop" ]; then
    for pid in $(cat $pid_list)
    do
        KILL $pid SIGINT
    done
else
    printf "Usage:\n\t%s start|stop [prefix]\n" "$0"
fi
