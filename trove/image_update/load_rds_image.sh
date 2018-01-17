#!/bin/bash

. ./common-functions || exit 1

if [ $# -ne 2 ]; then
    printf "Usage:\n\t%s <image id> <tag>\n" "$0"
    printf "Example:\n\t%s 3851910b55bb 1.1.4\n" "$0"
    exit 1
else
    image_id="$1"
    tag="$2"
fi

if [ ! -f ${image_id}.tar ]; then
    doCommand tar xzf "${image_id}".tgz
fi
doCommand docker load -i "${image_id}".tar
doCommand docker tag "$image_id" docker.cloudin.com/trove/rds:"$tag"
