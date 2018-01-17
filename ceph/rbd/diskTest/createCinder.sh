#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval $*
    [ $? -eq 0 ] || exit 1
}

cinderCreate() {
    doCommand cinder create $1 --name $2 --volume-type $3

    local ID=$(getCinderID $2)
    ID_list="$ID_list $ID"

    findCinderPosition $ID $2
}

getCinderID() {
    cinder list --all | grep " $1 " | awk '{print $2}'
}

findCinderPosition() {
    local host_attr=$(cinder show $1 | awk '/ os-vol-host-attr:host /{print $4}')
    local host=$(echo ${host_attr%%@*})
    local latter=$(echo ${host_attr##*@})
    local former=$(echo ${latter%%#*})
    local type_name=$(echo ${former##*-})
    echo $host /dev/volume-group-$type_name/volume-$1 $2 >> diskList.log
}

waitCinderAvailable() {
    while true
    do
        local status=$(cinder show $1 | awk '/ status /{print $4}')
        if [ $status = "available" ]; then
            break
        fi
        echo "wait available of $1"
        sleep 3
    done
}

tag=qrCloudin
volume_size_list=(5 20 50)
volume_type_list=(lvm_sata lvm_ssd lvm_pcie)

ID_list=""
>diskList.log

for volume_type in ${volume_type_list[@]}
do
    for volume_size in ${volume_size_list[@]}
    do
        volume_name=${tag}_${volume_type}_${volume_size}
        cinderCreate $volume_size $volume_name $volume_type
    done
done

for ID in $ID_list
do
    waitCinderAvailable $ID
done
