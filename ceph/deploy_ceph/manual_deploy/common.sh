#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

stop_process() {
    local pfn="$1" pid

    pid=$(pgrep -f "$pfn")
    if [ $? -ne 0 ]; then
        return 0
    fi

    doCommand kill "$pid"
    # Waiting for the process exits
    while :
    do
        pgrep -f "$pfn" > /dev/null
        if [ $? -ne 0 ]; then
            break
        fi

        sleep 1
    done
}

restart_process() {
    local pfn="$1"

    stop_process "$pfn"
    doCommand "$pfn"
}
