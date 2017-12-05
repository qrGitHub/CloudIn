#!/usr/bin/env python
#-*- coding:utf-8 -*-

import boto3, json
import pprint

bucket_name = 'lyb'
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
        'PreventHotLinkingAllowNull': {
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
                        'StringNotLike': {'aws:Referer': ['http://192.168.63.233*']}
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:*',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringNotLike': {'aws:Referer': ['http://192.168.63.23*']}
                    }
                }
            ]
        },
        'PreventHotLinkingDenyNull1': {
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
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        "Null": {"aws:Referer": "true"}
                    }
                }
            ]
        },
        'PreventHotLinkingDenyNull2': {
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
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringNotLikeIfExists': {'aws:Referer': ['http://192.168.63.23*']}
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
                        'IpAddress': {'aws:SourceIp': ['10.3.0.0/24', '172.16.1.5/32']},
                        'NotIpAddress': {'aws:SourceIp': '10.3.0.101/32'}
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

# creating a client
s3client = boto3.client('s3',
                        aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
                        aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
                        endpoint_url = 'http://172.16.1.4:7480')

#print_dict(bucket_policy_list)
put_bucket_policy(bucket_name, bucket_policy_list['AnonymousRead']) # PreventHotLinkingAllowNull PreventHotLinkingDenyNull[1-2] AnonymousRead SpecificIPv4
#get_bucket_policy(bucket_name)
#del_bucket_policy(bucket_name)
