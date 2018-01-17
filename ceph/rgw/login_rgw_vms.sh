#!/bin/bash

case $1 in
    wan1)
        ip=172.22.1.16
        ;;
    wan2)
        ip=172.22.1.17
        ;;
    wan3)
        ip=172.22.1.18
        ;;
    lan1)
        ip=172.22.1.21
        ;;
    lan2)
        ip=172.22.1.22
        ;;
    lan3)
        ip=172.22.1.23
        ;;
    dns1)
        ip=172.22.1.19
        ;;
    dns2)
        ip=172.22.1.20
        ;;
    *)
        printf "Usage\n\t%s <wan1|wan2|wan3|lan1|lan2|lan3|dns1|dns2>\n" "$0"
        exit 1
esac

ssh root@$ip
