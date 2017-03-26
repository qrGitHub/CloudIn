#!/bin/bash

function scandir02() {
    local cur_dir workdir
    workdir="$1"
    cd "$workdir"
    if [ "$workdir" = "/" ]; then
        cur_dir=""
    else
        cur_dir=$(pwd)
    fi
    
    for item in $(ls "$cur_dir")
    do
        if test -d "$item"; then
            cd "$item"
            scandir02 "$cur_dir/$item"
            cd ..
        else
            echo "$cur_dir/$item"
        fi
    done
}

function scandir() {
    for item in "$1"/*
    do
        if test -d "$item"; then
            scandir "$item"
        else
            echo "$item"
        fi
    done
}
 
if test -d "$1"; then
    scandir "${1%/}"
else
    echo "$1 is not a valid directory"
    exit 1
fi
