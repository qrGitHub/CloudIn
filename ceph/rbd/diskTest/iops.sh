#!/bin/bash

while read line
do
    ARR=($line)
    logFile=${ARR[2]}.log
    ssh ${ARR[0]} sudo fio -filename=${ARR[1]} -thread -group_reporting -direct=1 -ioengine=libaio -bs=4k -runtime=600 -numjobs=1 -rw=randrw -rwmixread=80 -iodepth=8 -iodepth_batch_submit=1 -iodepth_batch_complete=1 -name=${ARR[2]} > $logFile &
done < diskList.log

for pid in $(jobs -p)
do
    wait $pid
done
