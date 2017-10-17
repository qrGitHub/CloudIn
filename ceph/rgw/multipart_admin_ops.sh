#!/bin/bash

#ak=51BH4DAYS1LT2JBPVQ6D                     # admin user access key
#sk=nGF25LzdvFcHyV1zhpSKA4DDRaiJqT5hLVmLie4z # admin user secret key
ak=9I8980NI0DE7GMBHR4AL
sk=CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2

zone0_endpoint=172.16.1.103:7480
#zone0_endpoint=172.16.1.103:7480
zone1_endpoint=172.22.0.175:80
zone2_endpoint=oss-bj2.cloudin.cn

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
    local query="key-marker=$2"
    if [ ! -z "$3" ]; then
        query="$query&upload-id-marker="$(url_quote "$3")
    fi

    local date=$(DATE)
    local action=GET
    local header="${action}\n\n\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X ${action} "http://${endpoint}/${uri}&format=json&${query}" -H "Host: ${endpoint}"
    echo
}

get_all_parts() {
    local uri=$1/$2?uploadId=$3
    local date=$(DATE)
    local action=GET
    local header="${action}\n\n\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X ${action} "http://${endpoint}/${uri}&format=json" -H "Host: ${endpoint}" | python -m json.tool
}

abort_multipart_upload() {
    local uri=$1/$2?uploadId=$3
    local date=$(DATE)
    local action=DELETE
    local header="${action}\n\n\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X ${action} "http://${endpoint}/${uri}&format=json" -H "Host: ${endpoint}"
}

case $1 in
    0)
        endpoint=$zone0_endpoint
        shift
        ;;
    1)
        endpoint=$zone1_endpoint
        shift
        ;;
    2)
        endpoint=$zone2_endpoint
        shift
        ;;
    *)
        printf "Usage:\n\tbash %s <0|1|2> <operator> [<arg>...]\n" "$0"
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
