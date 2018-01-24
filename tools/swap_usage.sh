#!/bin/bash

if [ $# -ne 0 ]; then
    printf "Usage:\n\t bash %s | sort -k 5n -k1.5n\n" "$0"
    exit 0
fi

SUM=0
OVERALL=0

for DIR in $(find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]")
do
    PID=$(echo $DIR | cut -d / -f 3)
    PROGNAME=$(ps -p $PID -o comm --no-headers)
    for SWAP in $(grep Swap $DIR/smaps 2>/dev/null | awk '{ print $2 }')
    do
        let SUM=$SUM+$SWAP
    done

    echo "PID=$PID - Swap used: $SUM - ($PROGNAME)"
    let OVERALL=$OVERALL+$SUM
    SUM=0
done

echo "Overall swap used: $OVERALL"
