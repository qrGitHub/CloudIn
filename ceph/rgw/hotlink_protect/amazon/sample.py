#!/usr/bin/env python
#-*- coding:utf-8 -*-
import boto
import boto.s3.connection
import sys, os
import json
import pprint

bucket_name = 'myz'
key_name = 'cloudin-logo.png'

sk = os.environ.get('AWS_SECRET_ACCESS_KEY')
ak = os.environ.get('AWS_ACCESS_KEY_ID')
host = os.environ.get('AWS_HOST')

bucket_policy_list = {
        'AnonymousRead': {
            'Version':'2012-10-17',
            'Statement':[{
                'Sid':'AnonymousRead',
                'Effect':'Allow',
                'Principal': '*',
                'Action':['s3:GetObject'],
                'Resource':['arn:aws:s3:::%s/*' % bucket_name ]
            }]
        },
        'PreventHotLinking': {
            'Version': '2012-10-17',
            'Id': 'PreventHotLinking',
            'Statement': [
                {
                    'Sid': 'Allow get requests referred by 192.168.63.233',
                    'Effect': 'Allow',
                    'Principal': '*',
                    'Action': ['s3:GetObject'],
                    'Resource': [
                        'arn:aws:s3:::%s/*' % bucket_name
                    ],
                    'Condition': {
                        'StringLike': {'aws:Referer': ['http://192.168.63.23*']},
                        'StringNotLike': {'aws:Referer': ['http://192.168.63.232*']}
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:*',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringNotLike': {'aws:Referer': ['http://192.168.63.233*']}
                    }
                }
            ]
        },
        'SpecificIPv4': {
            'Version': '2012-10-17',
            'Id': 'SpecificIPv4',
            'Statement': [
                {
                    'Sid': 'IPAllow',
                    'Effect': 'Allow',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        #'IpAddress': {'aws:SourceIp': '121.69.56.174/16'},
                        'IpAddress': {'aws:SourceIp': '121.69.48.148/32'},
                        #'NotIpAddress': {'aws:SourceIp': '123.59.184.173/32'}
                    }
                }
            ]
        },
        'match_wildcards_bug': {
            'Version': '2012-10-17',
            'Id': 'match_wildcards_bug',
            'Statement': [
                {
                    'Sid': 'Explicit deny for specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringLike': {'aws:Referer': ['http://192.*32*']}
                        #'StringLike': {'aws:Referer': ['http://192.168.63.232*']}
                    }
                }
            ]
        },
}

def print_dict(dictionary):
    pp = pprint.PrettyPrinter(indent=1, width=80, depth=None, stream=None)
    pp.pprint(dictionary)

def get_all_buckets_sample():
    for bucket in conn.get_all_buckets():
        print "{name}\t{created}".format(name = bucket.name, created = bucket.creation_date)

def generate_url_v2_sample(bucket_name, key_name):
    print conn.generate_url(86400, 'GET', bucket=bucket_name, key=key_name, query_auth=True)
    print conn.generate_url(86400, 'GET', bucket=bucket_name, key=key_name, query_auth=False)

def generate_url_v4_sample(bucket_name, key_name):
    if not boto.config.get('s3', 'use-sigv4'):
        boto.config.add_section('s3')
        boto.config.set('s3', 'use-sigv4', 'True')

    # Get the service client with sigv4 configured
    s3 = boto.connect_s3(
            aws_access_key_id = ak,
            aws_secret_access_key = sk,
            is_secure = False, host = host, port = 80,
            calling_format = boto.s3.connection.OrdinaryCallingFormat())

    print s3.generate_url_sigv4(86400, 'GET', bucket=bucket_name, key=key_name)

def get_policy_sample(bucket_name):
    bucket = conn.get_bucket(bucket_name)
    try:
        result = json.loads(bucket.get_policy())
    except boto.exception.S3ResponseError as e:
        result = {}

    pp = pprint.PrettyPrinter()
    pp.pprint(result)

def set_policy_sample(bucket_name, bucket_policy):
    # Convert the policy to a JSON string
    bucket_policy = json.dumps(bucket_policy)

    # Set the new policy on the given bucket
    bucket = conn.get_bucket(bucket_name)
    return bucket.set_policy(bucket_policy)

def delete_policy_sample(bucket_name):
    bucket = conn.get_bucket(bucket_name)
    print bucket.delete_policy()

# creating a client
conn = boto.connect_s3(
        aws_access_key_id = ak,
        aws_secret_access_key = sk,
        is_secure = False, host = host, port = 80,
        calling_format = boto.s3.connection.OrdinaryCallingFormat())

#print_dict(bucket_policy_list)
#get_all_buckets_sample()
#generate_url_v2_sample(bucket_name, key_name)
generate_url_v4_sample(bucket_name, key_name)
#delete_policy_sample(bucket_name)
#set_policy_sample(bucket_name, bucket_policy_list['SpecificIPv4']) # PreventHotLinking AnonymousRead
#get_policy_sample(bucket_name)
