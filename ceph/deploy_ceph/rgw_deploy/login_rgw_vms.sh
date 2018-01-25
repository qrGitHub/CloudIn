#!/bin/bash

case $1 in
    wan1)
        ip=172.22.0.103
        ;;
    wan2)
        ip=172.22.0.104
        ;;
    wan3)
        ip=172.22.0.106
        ;;
    lan1)
        ip=172.22.0.108
        ;;
    lan2)
        ip=172.22.0.109
        ;;
    lan3)
        ip=172.22.0.110
        ;;
    dns1)
        ip=172.22.0.111
        ;;
    dns2)
        ip=172.22.0.112
        ;;
    *)
        printf "Usage\n\t%s <wan1|wan2|wan3|lan1|lan2|lan3|dns1|dns2>\n" "$0"
        exit 1
esac

ssh root@$ip
