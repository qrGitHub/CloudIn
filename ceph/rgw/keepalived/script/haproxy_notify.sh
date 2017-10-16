#!/bin/bash

test -r /etc/keepalived/script/haproxy_common.sh && . /etc/keepalived/script/haproxy_common.sh || exit 1

case "$1" in
    master)
        LOG Being master
        ;; 
    backup)
        LOG Being slave
        ;; 
    fault)
        LOG Now in Faulting state
        ;; 
    stop)
        LOG Now in Stopping state
        ;; 
    *)
        LOG "Usage: bash $0 <master|backup|fault|stop>"
        ;; 
esac
