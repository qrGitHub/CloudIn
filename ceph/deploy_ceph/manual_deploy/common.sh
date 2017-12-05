#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

stop_process() {
    local pid=$1 fpn="$2"

    doCommand kill "$pid"
    # Waiting for the process exits
    while :
    do
        pgrep -f "$fpn" > /dev/null
        if [ $? -ne 0 ]; then
            break
        fi

        sleep 1
    done
}

restart_process() {
    local pfn="$1" pid

    pid=$(pgrep -f "$pfn")
    if [ $? -eq 0 ]; then
        stop_process $pid "$pfn"
    fi

    doCommand "$pfn"
}
