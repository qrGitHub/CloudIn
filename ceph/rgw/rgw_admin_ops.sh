#!/bin/bash

ak=51BH4DAYS1LT2JBPVQ6D  # admin user access key
sk=nGF25LzdvFcHyV1zhpSKA4DDRaiJqT5hLVmLie4z # admin user secret key
endpoint=172.22.0.175:80

DATE() {
    for i in $(date "+%H")
    do
        date "+%a, %d %b %Y $((10#$i-8)):%M:%S +0000"
    done
}

get_user_info() {
    local operator=admin/user
    local param="&uid=$1"
    local date=$(DATE)
    local header="GET\n\n\n${date}\n/${operator}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X GET "http://${endpoint}/${operator}?format=json${param}" -H "Host: ${endpoint}"
    echo
}
#uid=$1 && get_user_info $uid

get_bucket_info() {
    local operator=admin/bucket
    local param="&bucket=$1&uid=$2&stats=True"
    local date=$(DATE)
    local header="GET\n\n\n${date}\n/${operator}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X GET "http://${endpoint}/${operator}?format=json${param}" -H "Host: ${endpoint}"
    echo
}

get_bucket_info $1 $2
