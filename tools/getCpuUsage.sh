#!/bin/bash

name="rsync -a"
if [ $# -ne 0 ]; then
    name="$*"
fi

totalCpuUsage=0
sampleCount=0
while :
do
    line=$(ps aux | grep "$name" | grep -v grep)
    if [ $? -ne 0 ]; then
        if [ $sampleCount -ne 0 ]; then
            awk -v x=$totalCpuUsage -v y=$sampleCount 'BEGIN {print x/y}'
            break
        fi

        sleep 3
        continue
    fi

    pid=$(echo $line | awk '{print $2}')
    cpuUsage=$(top -b -d 3 -n 2 -p $pid | grep -E '^\s*'$pid | tail -n 1 | awk '{print $9}')
    totalCpuUsage=$(awk -v x=$totalCpuUsage -v y=$cpuUsage 'BEGIN {print x+y}')
    let "sampleCount++"

    echo $cpuUsage
done
