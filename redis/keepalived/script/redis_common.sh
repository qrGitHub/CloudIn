#!/bin/bash

export MASTER_IP=10.1.0.110
export MASTER_PORT=6379
export PASSWORD=123456

LOGFILE=/etc/keepalived/redis-state.log
export REDISCLI=/usr/local/bin/redis-cli

LOG() {
    echo "$(date +'%F %T') $@" >> $LOGFILE
}

doCommand() {
    echo "$(date +'%F %T') $@" >> $LOGFILE
    eval "$@ >> $LOGFILE 2>&1"
}
