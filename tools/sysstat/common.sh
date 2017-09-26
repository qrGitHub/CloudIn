#!/bin/bash

string2array() {
    local OLD_IFS="$IFS"
    IFS="$2"
    local array=($1)
    IFS="$OLD_IFS"

    echo ${array[@]}
}

pname2pid() {
    pgrep -f "$1"
}

KILL() {
    local signal="$2"
    local pid="$1"

    kill -s "$signal" "$pid"
}
