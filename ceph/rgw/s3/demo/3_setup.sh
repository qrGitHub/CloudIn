#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

doCommand s3cmd mb s3://DEMO07
doCommand s3cmd put hello_world s3://DEMO07
