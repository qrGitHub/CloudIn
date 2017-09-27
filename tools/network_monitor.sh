#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    printf "Usage:\n\t%s <duration> <file>\n" "$0"
    exit 1
fi

interval=10
duration=$1
file=$2

>$file
while [ $duration -gt 0 ];
do
    iftop -i eth1 -n -t -s $interval >> $file 2>/dev/null
    let "duration -= interval"
done
