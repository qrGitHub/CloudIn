#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys, os, base64, datetime, hashlib, hmac
import requests # pip install requests

# s3 API - AWS Version 4
# This version makes a GET request and passes the signature in the Authorization header.

# ************* REQUEST VALUES *************
method = 'GET'
service = 's3'

region = os.environ.get('AWS_REGION')
uri_param = os.environ.get('AWS_URI_PARAM')
host = os.environ.get('AWS_HOST')

endpoint = 'http://{0}{1}'.format(host, uri_param)
request_parameters = 'acl='

# Match the algorithm to the hashing algorithm you use, either SHA-1 or SHA-256 (recommended)
algorithm = 'AWS4-HMAC-SHA256'
termination = 'aws4_request'

# Key derivation functions.
def sign(key, msg):
    return hmac.new(key, msg.encode('utf-8'), hashlib.sha256).digest()

def get_signing_key(key, dateStamp, regionName, serviceName):
    kDate = sign(('AWS4' + key).encode('utf-8'), dateStamp)
    kRegion = sign(kDate, regionName)
    kService = sign(kRegion, serviceName)
    kSigning = sign(kService, termination)

    return kSigning

# Read AWS access key from env variables or configuration file. Best practice is NOT
# to embed credentials in code.
access_key = os.environ.get('AWS_ACCESS_KEY_ID')
secret_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
if access_key is None or secret_key is None:
    print 'Access key or secret key is not available.'
    sys.exit(1)

# Create a date for headers and the credential string
t = datetime.datetime.utcnow()
amzdate = t.strftime('%Y%m%dT%H%M%SZ')
datestamp = t.strftime('%Y%m%d') # Date w/o time, used in credential scope

credential_scope = datestamp + '/' + region + '/' + service + '/' + termination
canonical_querystring = ''
signed_headers = ''
payload_hash = ''

# ************* TASK 1: CREATE A CANONICAL REQUEST *************
def Create_a_Canonical_Request():
    global canonical_querystring, signed_headers, payload_hash
    # Step 1 is to define the verb (GET, PUT, POST, etc.)

    # Step 2: Create canonical URI -- the part of the URI from domain to query string
    canonical_uri = uri_param

    # Step 3: Create the canonical query string. Query string values must
    # be URL-encoded (space=%20). The parameters must be sorted by name.
    canonical_querystring = request_parameters

    # Step 5: Create the list of signed headers. This lists the headers
    # in the canonical_headers list, delimited with ";" and in alpha order.
    signed_headers = 'host;x-amz-content-sha256;x-amz-date'

    # Step 6: Create payload hash(hash of the request body content). For GET
    # requests, the payload is an empty string ("").
    payload_hash = hashlib.sha256('').hexdigest()

    # Step 4: Create the canonical headers. Header names must be trimmed and
    # lowercase, and sorted in code point order from low to high.
    # Note that there is a trailing \n.
    canonical_headers = 'host:' + host + '\n' + 'x-amz-content-sha256:' + payload_hash + '\n' + 'x-amz-date:' + amzdate + '\n'

    # Step 7: Combine elements to create canonical request
    return method + '\n' + canonical_uri + '\n' + canonical_querystring + '\n' + canonical_headers + '\n' + signed_headers + '\n' + payload_hash

# ************* TASK 2: CREATE A STRING TO SIGN *************
def Create_a_String_to_Sign(canonical_request):
    return algorithm + '\n' + amzdate + '\n' + credential_scope + '\n' + hashlib.sha256(canonical_request).hexdigest()

# ************* TASK 3: CALCULATE THE SIGNATURE *************
def Calculate_the_Signature(string_to_sign):
    # Create the signing key
    signing_key = get_signing_key(secret_key, datestamp, region, service)

    # Sign the string_to_sign using the signing_key
    return hmac.new(signing_key, (string_to_sign).encode('utf-8'), hashlib.sha256).hexdigest()

# ************* TASK 4: ADD SIGNING INFORMATION TO THE REQUEST *************
# The signing information can be either in a header named Authorization or in a query string value
def Create_Authorization_Header(signature):
    authorization = '{0} Credential={1}/{2}, SignedHeaders={3}, Signature={4}'.format(algorithm, access_key, credential_scope, signed_headers, signature)

    # The request can include any headers, but MUST include "host", "x-amz-date",
    # and (for this scenario) "Authorization". "host" and "x-amz-date" must
    # be included in the canonical_headers and signed_headers, as noted
    # earlier. Order here is not significant.
    # Python note: The 'host' header is added automatically by the Python 'requests' library.
    headers = {
            'Authorization': authorization,
            'x-amz-content-sha256': payload_hash,
            'x-amz-date': amzdate,
    }

    return headers
def Create_QueryString(signature):
    pass

canonical_request = Create_a_Canonical_Request()
string_to_sign = Create_a_String_to_Sign(canonical_request)
signature = Calculate_the_Signature(string_to_sign)
headers = Create_Authorization_Header(signature)

# ************* SEND THE REQUEST *************
request_url = endpoint + '?' + canonical_querystring

print 'Request   URL:', request_url
r = requests.get(request_url, headers=headers)

print 'Response code: %d' % r.status_code
print r.text
