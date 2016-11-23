#!/bin/bash

function getNetValue() {
    ipInfo=$(ifconfig | grep -A 1 '^eth0' | grep 'inet addr:')
    echo $ipInfo | \
        awk -v pattern="$1" ' \
        {
            for (i = 1; i <= NF; i++) { \
                if ($i ~ pattern) { \
                    split($i, list, ":"); \
                    print list[2]; \
                } \
            } \
        }'
}

function dhcp2static() {
    sed -i 's/\(iface eth0 inet\) dhcp/\1 static/' $1

    grep "^address " $1 > /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\naddress $2" >> $1
    fi

    grep "^netmask " $1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "netmask $3" >> $1
    fi
}

function verifyGateway() {
    ip2intArray $2
    gw=${ipArray[0]}.${ipArray[1]}.${ipArray[2]}.1

    grep "^gateway " $1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "gateway $gw" >> $1
    fi
}

function verifyMTU() {
    mtuLine="mtu 1450"
    grep "^$mtuLine" $1 > /dev/null
    if [ $? -ne 0 ]; then
        echo $mtuLine >> $1
    fi
}

function ip2intArray() {
    local ipList=${1//./ }
    read -a ipArray <<< $ipList
}

cfg=/etc/network/interfaces
ipAddr=$(getNetValue "addr:")
mask=$(getNetValue "Mask:")

dhcp2static $cfg $ipAddr $mask
verifyGateway $cfg $ipAddr
verifyMTU $cfg

sudo nohup sh -c "ifdown eth0 && ifup eth0"
