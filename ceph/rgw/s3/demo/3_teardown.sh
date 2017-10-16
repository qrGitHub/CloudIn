#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

doCommand s3cmd del s3://DEMO07/hello_world
doCommand s3cmd rb s3://DEMO07
