#!/usr/bin/env python
#-*- coding:utf-8 -*-

from bucket_policy_list import bucket_policy_list
import boto3, json
import pprint, os

def print_dict(dictionary):
    pp = pprint.PrettyPrinter(indent=1, width=80, depth=None, stream=None)
    pp.pprint(dictionary)

def dict2string(dictionary):
    for name in dictionary:
        string_policy = json.dumps(dictionary[name]).replace('"', '\\"')
        print '{0}\n"{1}"\n'.format(name, string_policy)

def put_bucket_policy(bucket_name, bucket_policy):
    # Convert the policy to a JSON string
    bucket_policy = json.dumps(bucket_policy)

    # Set the new policy on the given bucket
    return s3client.put_bucket_policy(Bucket=bucket_name, Policy=bucket_policy)

def get_bucket_policy(bucket_name):
    # Call to S3 to retrieve the policy for the given bucket
    result = s3client.get_bucket_policy(Bucket=bucket_name)

    pp = pprint.PrettyPrinter()
    pp.pprint(result)

def del_bucket_policy(bucket_name):
    # Call S3 to delete the policy for the given bucket
    print s3client.delete_bucket_policy(Bucket=bucket_name)

bucket_name = 'lyb'

# creating a client
s3client = boto3.client('s3',
                        aws_secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY'),
                        aws_access_key_id = os.environ.get('AWS_ACCESS_KEY_ID'),
                        endpoint_url = 'http://172.16.1.4:7480')

#print_dict(bucket_policy_list)
#dict2string(bucket_policy_list)
put_bucket_policy(bucket_name, bucket_policy_list['SpecificUser']) # PreventHotLinkingAllowNull PreventHotLinkingDenyNull[1-2] AnonymousRead SpecificIPv4 SpecificPrincipal
get_bucket_policy(bucket_name)
#del_bucket_policy(bucket_name)
