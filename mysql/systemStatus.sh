#!/bin/bash

interval=5
prefix=$interval-sec-status
runfile=/root/running
mysql -e 'show global variables' -uroot -p111111 >> mysql-variables

while test -e $runfile;
do
    file=$(date +%F_%I)
    sleep=$(date +%s.%N | awk "{print $interval - (\$1 % $interval)}")
    sleep $sleep
    ts="$(date +'TS %s.%N %F %T')"
    loadavg="$(uptime)"
    echo "$ts $loadavg" >> $prefix-${file}-status
    mysql -e 'show global status' -uroot -p111111 >> $prefix-${file}-status &
    echo "$ts $loadavg" >> $prefix-${file}-innodbstatus
    mysql -e 'show engine innodb status\G' -uroot -p111111 >> $prefix-${file}-innodbstatus &
    echo "$ts $loadavg" >> $prefix-${file}-processlist
    mysql -e 'show full processlist\G' -uroot -p111111 >> $prefix-${file}-processlist &
    echo $ts
done

echo Exiting because $runfile does not exist.
