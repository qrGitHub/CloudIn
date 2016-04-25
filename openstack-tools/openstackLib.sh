#!/bin/bash

setupOpenstackEnvironment() {
    if [ ! "$OS_PROJECT_NAME" ]; then
        source /opt/osdeploy/admin_openrc.sh
    fi
}

doCommand() {
    echo "^_^ doCommand: $*"
    eval $*
    [ $? -eq 0 ] || exit 1
}

waitUntilActive() {
    while [ 1 ]
    do
        serverStatus=$(eval $*)
        if [ "$serverStatus" == "ACTIVE" ]; then
            break
        elif [ "$serverStatus" == "ERROR" ]; then
            echo "$*: $serverStatus"
            exit 1
        fi
        sleep 5
    done
}

