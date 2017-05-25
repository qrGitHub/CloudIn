#!/bin/bash

export PEER_IP=$PEER_IP
export MASTER_PORT=6379
export PASSWORD=$(awk '/^requirepass/{print $2; exit}' $REDIS_CONF)

LOGFILE=/etc/keepalived/redis-state.log
export REDISCLI=/usr/local/bin/redis-cli

LOG() {
    echo "$(date +'%F %T') $@" >> $LOGFILE
}

doCommand() {
    echo "$(date +'%F %T') $@" >> $LOGFILE
    eval "$@ >> $LOGFILE 2>&1"
}

do_config() {
    doCommand "$REDISCLI" -a "$PASSWORD" CONFIG "$@"
}

enable_slave() {
    doCommand "$REDISCLI" -a "$PASSWORD" SLAVEOF "$PEER_IP" "$MASTER_PORT"
}

disable_slave() {
    doCommand "$REDISCLI" -a "$PASSWORD" SLAVEOF NO ONE
}

enable_RDB() {
    do_config SET SAVE \"900 1 300 10 60 10000\"
}

disable_RDB() {
    do_config SET SAVE \"\"
}

enable_AOF() {
    do_config SET APPENDONLY yes
}

disable_AOF() {
    do_config SET APPENDONLY no
}

config_master() {
    disable_slave
    disable_AOF
    disable_RDB

    do_config REWRITE
}

config_slave() {
    enable_RDB
    enable_AOF
    enable_slave

    do_config REWRITE
}
