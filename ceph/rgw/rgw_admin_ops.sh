#!/bin/bash

ak=51BH4DAYS1LT2JBPVQ6D                     # admin user access key
sk=nGF25LzdvFcHyV1zhpSKA4DDRaiJqT5hLVmLie4z # admin user secret key

zone0_endpoint=172.16.1.103:7480
#zone0_endpoint=172.16.1.103:7480
zone1_endpoint=172.22.0.175:80
zone2_endpoint=oss-bj2.cloudin.cn

DATE() {
    date -u "+%a, %d %b %Y %H:%M:%S %Z"
}

prepare_parameters() {
    local array=($@)
    local param=""

    for i in ${array[@]}
    do
        if [ -z "$param" ]; then
            param="uid=$i"
        else
            param="$param&$i"
        fi
    done

    echo $param
}

get_user_info() {
    local uri=admin/user
    local query="uid=$1"
    local date=$(DATE)
    local header="GET\n\n\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X GET "http://${endpoint}/${uri}?format=json&${query}" -H "Host: ${endpoint}"
}

get_bucket_info() {
    local uri=admin/bucket
    local query="bucket=$1&stats=True"
    local date=$(DATE)
    local header="GET\n\n\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X GET "http://${endpoint}/${uri}?format=json&${query}" -H "Host: ${endpoint}"
}

get_usage() {
    local uri=admin/usage
    local date=$(DATE)
    local header="GET\n\n\n${date}\n/${uri}"
    local sig=$(echo -en ${header} | openssl sha1 -hmac ${sk} -binary | base64)
    local query=$(prepare_parameters $@)

    curl -v -H "Date: ${date}" -H "Authorization: AWS ${ak}:${sig}" -L -X GET "http://${endpoint}/${uri}?format=json&${query}" -H "Host: ${endpoint}"
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
        printf "\tbash %s 2 get_bucket_info <bucket>\n" "$0"
        printf "\tbash %s 2 get_user_info <uid>\n" "$0"
        printf "\tbash %s 2 get_usage <uid> [start=YYYY-mm-dd%%20HH:MM:SS] [end=YYYY-mm-dd%%20HH:MM:SS]\n" "$0" # 不传start和end就是list全部
        exit 1
esac

$@ | python -m json.tool
