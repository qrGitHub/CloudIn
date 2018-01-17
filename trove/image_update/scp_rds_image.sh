#!/bin/bash

. ./common-functions || exit 1

if [ $# -ne 2 ]; then
    printf "Usage:\n\t%s <image id> <host>\n" "$0"
    printf "Example:\n\t%s 3851910b55bb 123.59.184.133\n" "$0"
    exit 1
else
    image_id="$1"
    host="$2"
fi

doCommand docker save -o "${image_id}".tar "$image_id"
doCommand tar czf "${image_id}".tgz "${image_id}".tar
doCommand scp -l 5000 "${image_id}".tgz "${host}":/tmp/
