#!/bin/bash

test -r /etc/keepalived/script/redis_common.sh && . /etc/keepalived/script/redis_common.sh || exit 1

LOG Being slave

config_slave
