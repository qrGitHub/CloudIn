#!/bin/bash
# https://geek.co.il/2014/11/19/script-day-amazon-aws-signature-version-4

# figure out how to generate SHA256 hashes (support Linux and FreeBSD)
which sha256sum >/dev/null 2>&1 && HASH=sha256sum || HASH=sha256
# shorthand for a verbose mktemp call that works on FreeBSD
MKTEMP="mktemp -t aws-sign.XXXXXX"
 
format_date_from_epoch() { # FreeBSD has an annoyingly non GNU-like data utility
    local epoch="$1" format="$2"

    if uname | grep -q FreeBSD; then
        date -u -jf %s $epoch "$format"
    else
        date -u -d @$epoch "$format"
    fi
}
 
hex_hash() { # generate a hex-encoded SHA256 hash value
    local data="$1"
    printf "%s" "$data" | $HASH | awk '{print $1}'
}

hmac() {
    local key="$1" data="$2"
    printf "$data" | openssl dgst -binary -sha256 -mac HMAC -macopt hexkey:$key | xxd -p -c 256
}
 
hmac2() {
    local keyfile="$1" data="$2"
    printf "%s" "$data" | openssl dgst -sha256 -mac HMAC -macopt hexkey:"$(hex < $keyfile)" -binary
}
 
hex() { # pipe conversion of binary data to hexencoded byte stream
    # Note: it will mess up if you send more than 256 bytes, which is the maximum column size for xxd output
    xxd -p -c 256
}
 
derive_signing_key() {
    local user_secret="$1" message_date="$2" aws_region="$3" aws_service="$4"
    local step0="$($MKTEMP)" step1="$($MKTEMP)" step2="$($MKTEMP)" step3="$($MKTEMP)"

    printf "%s" "AWS4${user_secret}" > $step0
    hmac2 "$step0" "${message_date}" > $step1
    hmac2 "$step1" "${aws_region}" > $step2
    hmac2 "$step2" "${aws_service}" > $step3
    hmac2 "$step3" "aws4_request"
    rm -f $step0 $step1 $step2 $step3
}

Create_a_Canonical_Request() {
    local method="$1" uri="${2:-/}" querystring="$3" payload_hash="$4"
    local endpoint="$5" message_time="$6" signed_headers="$7"
    local headers

    headers="$(printf "host:${endpoint}\nx-amz-content-sha256:${payload_hash}\nx-amz-date:${message_time}")"
    printf "${method}\n${uri}\n${querystring}\n${headers}\n\n${signed_headers}\n${payload_hash}"
}

Create_a_String_to_Sign() {
    local message_time="$1" credential_scope="$2" canonical_request="$3" canonical_request_hash

    canonical_request_hash=$(hex_hash "$canonical_request")
    printf "${algorithm}\n${message_time}\n${credential_scope}\n${canonical_request_hash}"
}

Calculate_the_Signature() {
    local user_secret="$1" message_date="$2" aws_region="$3" aws_service="$4" string_to_sign="$5"
    local kSecret kDate kRegion kService kSigning

    kSecret=$(printf "AWS4${user_secret}" | xxd -p -c 256)
    kDate=$(hmac $kSecret $message_date)
    kRegion=$(hmac $kDate $aws_region)
    kService=$(hmac $kRegion $aws_service)
    kSigning=$(hmac $kService "aws4_request")
    printf "$string_to_sign" | openssl dgst -binary -sha256 -mac HMAC -macopt hexkey:$kSigning -hex | sed 's/^.* //'
}

Calculate_the_Signature2() {
    local user_secret="$1" message_date="$2" aws_region="$3" aws_service="$4" string_to_sign="$5"
    local signing_key="$($MKTEMP)"

    derive_signing_key "${user_secret}" "${message_date}" "${aws_region}" "${aws_service}" > $signing_key
    hmac2 "${signing_key}" "${string_to_sign}" | hex

    rm -f $signing_key
}

# Call with all the details to produce the signing headers for an HTTP request
get_authorization_headers() {
    # Input parameters:
    #     User key [required]
    #     User secret [required]
    #     Timestamp for the request, as an epoch time. If omitted, it will use the current time [optional]
    #     AWS region this request will be sent to. If omitted, will use "us-east-1" [optional]
    #     AWS service that will receive this request. [required]
    #     Request address. If omitted (for example for calls without a path part), "/" is assumed to be congruent with the protocol. [optional]
    #     Request query string, after sorting. May be empty for POST requests [optional]
    #     POST request body. May be empty for GET requests [optional]
    local user_key="$1" user_secret="$2" timestamp="${3:-$(date +%s)}" aws_region="${4:-us-east-1}"
    local aws_service="$5" uri="${6:-/}" query_string="$7" request_payload="$8" method="$9" endpoint="${10}"
    local message_date message_time signed_headers payload_hash canonical_request credential_scope string_to_sign signature
 
    message_date="$(format_date_from_epoch $timestamp +%Y%m%d)"
    message_time="$(format_date_from_epoch $timestamp +${message_date}T%H%M%SZ)"

    # TASK 1: CREATE A CANONICAL REQUEST
    signed_headers="host;x-amz-content-sha256;x-amz-date"
    payload_hash=$(hex_hash "$request_payload")
    canonical_request="$(Create_a_Canonical_Request $method $uri $query_string "$payload_hash" $endpoint $message_time $signed_headers)"

    # TASK 2: CREATE A STRING TO SIGN
    credential_scope="${message_date}/${aws_region}/${aws_service}/aws4_request"
    string_to_sign=$(Create_a_String_to_Sign "$message_time" "$credential_scope" "$canonical_request")

    # TASK 3: CALCULATE THE SIGNATURE
    signature=$(Calculate_the_Signature "$user_secret" "$message_date" "$aws_region" "$aws_service" "$string_to_sign")
    #signature=$(Calculate_the_Signature2 "$user_secret" "$message_date" "$aws_region" "$aws_service" "$string_to_sign")
 
    echo "X_Amz_Date: ${message_time}"
    echo "X_Amz_Content_SHA256: ${payload_hash}"
    echo "Authorization: ${algorithm} Credential=${user_key}/${credential_scope}, SignedHeaders=${signed_headers}, Signature=${signature}"
}

algorithm=AWS4-HMAC-SHA256
access_key="9I8980NI0DE7GMBHR4AL"
secret_key="CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2"
endpoint="172.16.1.4:7480"
uri=/lyb
query_string="acl="
aws_service="s3"
method=GET

authorization_headers=$(get_authorization_headers "$access_key" "$secret_key" "" "" "$aws_service" "$uri" "$query_string" "" "$method" "$endpoint" | sed 's,^,-H ",' | sed 's,$,",')
IFS=$'\n' read -rd '' -a curl_headers <<< "$authorization_headers"
#authorization_headers=$(get_authorization_headers "$access_key" "$secret_key" "" "" "$aws_service" "$uri" "$query_string" "" "$method" "$endpoint" | sed 's,^,-H ",' | sed 's,$,",')
#IFS=$'\n' read -rd '' -a curl_headers < <(echo $authorization_headers)
eval curl -v ${curl_headers[@]} "http://${endpoint}${uri}?${query_string}"
echo
