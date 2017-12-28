#!/bin/bash

#ak=$ADMIN_ACCESS_KEY_ID                     # admin user access key
#sk=$ADMIN_SECRET_ACCESS_KEY                 # admin user secret key
ak=$AWS_ACCESS_KEY_ID
sk=$AWS_SECRET_ACCESS_KEY

zone0_endpoint=$AWS_HOST
zone2_endpoint=oss-bj2.cloudin.cn
zone3_endpoint=oss-bj3.cloudin.cn

DATE() {
    date -u "+%a, %d %b %Y %H:%M:%S %Z"
}

ASCII=('~')
URL=('%7E')
url_quote() {
    local string="$1"
    for ((i=0; i<${#ASCII[@]}; i++))
    do
        string=$(echo $string | sed 's/'${ASCII[$i]}'/'${URL[$i]}'/g')
    done
    echo $string
}

list_multipart_uploads() {
    local uri=$1/?uploads
    local date=$(DATE)
    local method=GET content_md5 content_type
    local header="${method}\n${content_md5}\n${content_type}\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)
    local query="key-marker=$2"
    if [ ! -z "$3" ]; then
        query="$query&upload-id-marker="$(url_quote "$3")
    fi

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" "http://${endpoint}/${uri}&format=json&${query}" | python -m json.tool
}

get_all_parts() {
    local uri=$1/$2?uploadId=$3
    local date=$(DATE)
    local method=GET content_md5 content_type
    local header="${method}\n${content_md5}\n${content_type}\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" "http://${endpoint}/${uri}&format=json" | python -m json.tool
}

abort_multipart_upload() {
    local uri=$1/$2?uploadId=$3
    local date=$(DATE)
    local method=DELETE content_md5 content_type
    local header="${method}\n${content_md5}\n${content_type}\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" "http://${endpoint}/${uri}&format=json" -X ${method} | python -m json.tool
}

case $1 in
    0)
        endpoint=$zone0_endpoint
        shift
        ;;
    2)
        endpoint=$zone2_endpoint
        shift
        ;;
    3)
        endpoint=$zone3_endpoint
        shift
        ;;
    *)
        printf "Usage:\n\tbash %s <0|2|3> <operator> [<arg>...]\n" "$0"
        printf "Example:\n"
        printf "\tbash %s 0 list_multipart_uploads <bucket> <object> [<upload id marker>]\n" "$0"
        printf "\tbash %s 0 get_all_parts <bucket> <object> <upload id>\n" "$0"
        printf "\tbash %s 0 abort_multipart_upload <bucket> <object> <upload id>\n" "$0"
        exit 1
esac

$@
#list_multipart_uploads lyb
#         get_all_parts lyb multipart_test 2~uGC0eXrl7SNg66zPm_ZUGkVDzJUZkUe
#abort_multipart_upload lyb multipart_test 2~uGC0eXrl7SNg66zPm_ZUGkVDzJUZkUe
