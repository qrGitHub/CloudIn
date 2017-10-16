#!/bin/bash

LOGFILE=/etc/keepalived/haproxy-state.log

LOG() {
    echo "$(date +'%F %T') $@" >> $LOGFILE
}

doCommand() {
    echo "$(date +'%F %T') $@" >> $LOGFILE
    eval "$@ >> $LOGFILE 2>&1"
}
