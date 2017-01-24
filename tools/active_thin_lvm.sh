#!/bin/bash

doCommand() {
    echo "^_^ $FUNCNAME: $*"
    eval "$@"
    [ $? -eq 0 ] || exit 1
}

get_thin_lvms() {
    sudo lvs | while read line
    do
        if [[ "$line" =~ ^LV' '+VG' '+Attr ]]; then
            continue
        fi

        arr=($line)
        if [[ ${arr[2]} =~ ^V|^t|^T ]]; then
            echo "/dev/${arr[1]}/${arr[0]}"
        fi
    done
}

lvm_is_available() {
    local status=($(sudo lvdisplay "$1" | grep 'LV Status'))
    if [ "${status[2]}" = 'available' ]; then
        return 0
    fi

    return 1
}

package_name="thin-provisioning-tools"
dpkg -l | grep -q "$package_name"
if [ $? -ne 0 ]; then
    doCommand apt-get install -y "$package_name"
fi

lvm_list=$(get_thin_lvms)
for item in $lvm_list
do
    lvm_is_available "$item"
    if [ $? -ne 0 ]; then
        doCommand sudo lvchange -a y "$item"
    fi
done
