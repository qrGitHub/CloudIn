#!/bin/bash

doCommand() {
    echo -n "^_^ doCommand: $*"
    read

    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
    sleep 2

    echo 
}

doCommand s3cmd ls
# create bucket
doCommand s3cmd mb s3://DEMO
doCommand s3cmd ls
# upload object
doCommand s3cmd put hello_world s3://DEMO
doCommand s3cmd ls s3://DEMO
# download object
doCommand s3cmd get s3://DEMO/hello_world local_file
# multipart upload
doCommand s3cmd --multipart-chunk-size-mb=5 put largefile s3://DEMO
doCommand s3cmd ls s3://DEMO
# delete object
doCommand s3cmd del s3://DEMO/largefile
doCommand s3cmd del s3://DEMO/hello_world
# delete bucket
doCommand s3cmd rb s3://DEMO

rm -f local_file
