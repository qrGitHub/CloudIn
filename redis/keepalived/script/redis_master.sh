#!/bin/bash

test -r /etc/keepalived/script/redis_common.sh && . /etc/keepalived/script/redis_common.sh || exit 1

LOG Being master

doCommand "$REDISCLI" -a "$PASSWORD" SLAVEOF NO ONE
