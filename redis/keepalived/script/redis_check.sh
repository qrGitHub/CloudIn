#!/bin/bash

test -r /etc/keepalived/script/redis_common.sh && . /etc/keepalived/script/redis_common.sh || exit 1

"$REDISCLI" -a "$PASSWORD" ping > /dev/null 2>&1
