#!/bin/bash

doCommand() {
    echo "^_^ $FUNCNAME: $*"
    eval "$@"
    [ $? -eq 0 ] || exit 1
}

generate_ipv4()
{
    let "p1 = RANDOM % 256"
    let "p2 = RANDOM % 256"
    let "p3 = RANDOM % 256"
    let "p4 = RANDOM % 256"

    echo "$p1.$p2.$p3.$p4"
}

PASSWORD=qazwsx
COUNT=2

REDISCLI="redis-cli -a $PASSWORD -n 1 SET"
ID=1

while ((ID <= COUNT))
do
    INSTANCE_NAME="i-VM-$ID"
    UUID=$(cat /proc/sys/kernel/random/uuid)
    PRIVATE_IP_ADDRESS=$(generate_ipv4)
    CREATED=$(date "+%Y-%m-%d %H:%M:%S")

    doCommand "$REDISCLI vm_instance:$ID:instance_name $INSTANCE_NAME"
    doCommand "$REDISCLI vm_instance:$ID:uuid $UUID"
    doCommand "$REDISCLI vm_instance:$ID:private_ip_address $PRIVATE_IP_ADDRESS"
    doCommand "$REDISCLI vm_instance:$ID:created \"$CREATED\""
    doCommand "$REDISCLI vm_instance:$INSTANCE_NAME:id $ID"

    ID=$((ID + 1))
done
