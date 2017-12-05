#!/bin/bash

generate_uncompleted_multipartupload() {
    /root/.oss/bin/python /root/rgw/s3/usage/boto_multipart.py
}

abort_uncompleted_multipartupload() {
    local bucket=$1 object=$2

    upload_id=$(bash multipart_admin_ops.sh 0 list_multipart_uploads $bucket $object | python -m json.tool | grep NextUploadIdMarker | awk -F: '{print $2}' | sed 's/[ ,"]//g')
    if [ ! -z "$upload_id" ]; then
        bash multipart_admin_ops.sh 0 abort_multipart_upload $bucket $object $upload_id
    fi
}

bucket=lyb
object=512K

case $1 in
    init)
        generate_uncompleted_multipartupload
        ;;
    list)
        bash multipart_admin_ops.sh 0 list_multipart_uploads $bucket $object
        ;;
    abort)
        abort_uncompleted_multipartupload $bucket $object
        ;;
    *)
        printf "Usage:\n\t%s init|list|abort\n" $0
        exit 1
esac
