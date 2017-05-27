#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

get_all_images() {
    rbd ls -p "$1"
}

get_all_glances() {
    glance image-list --all | awk '/[0-9a-z]-[0-9a-z]/{print $2}'
}

image_is_in_use() {
    for item in ${all_glances[@]}
    do
        if [ "$1" = "$item" ]; then
            return 0
        fi
    done

    return 1
}

remove_unused_images() {
    for image in $(get_all_images "$1")
    do
        image_is_in_use "$image"
        if [ $? -ne 0 ]; then
            doCommand rbd rm -p images "$image"
        fi
    done
}

pool_name=images
all_glances=($(get_all_glances))
remove_unused_images "$pool_name"
