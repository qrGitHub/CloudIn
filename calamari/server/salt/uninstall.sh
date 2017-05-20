#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

doCommand sudo dpkg -r salt-syndic
doCommand sudo dpkg -r salt-master
doCommand sudo dpkg -r salt-minion
doCommand sudo dpkg -r salt-common
