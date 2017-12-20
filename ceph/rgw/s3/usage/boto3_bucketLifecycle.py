#!/usr/bin/env python
#-*- coding:utf-8 -*-

import boto3, json
import pprint, os

bucket_name = 'lyb'
bucket_lifecycle_list = {
    'demo1': {
        'Rules': [
            {
                'ID': 'demo1',
                'Prefix': 'test',
                'Status': 'Enabled',
                'Expiration': {
                    'Days': 30,
                },
            },
        ]
    },
    'demo2': {
        'Rules': [
            {
                'ID': 'demo2',
                'Prefix': '/abc',
                'Status': 'Enabled',
                'Expiration': {
                    'Days': 123,
                },
                'AbortIncompleteMultipartUpload': {
                    'DaysAfterInitiation': 123
                }
            },
        ]
    },
}

def print_dict(dictionary):
    pp = pprint.PrettyPrinter(indent=1, width=80, depth=None, stream=None)
    pp.pprint(dictionary)

def put_bucket_lifecycle(bucket_name, lifecycle):
    # Set the new lifecycle on the given bucket
    return s3client.put_bucket_lifecycle(Bucket=bucket_name, LifecycleConfiguration=lifecycle)

def get_bucket_lifecycle(bucket_name):
    # Call to S3 to retrieve the lifecycle for the given bucket
    # get_bucket_lifecycle or get_bucket_lifecycle_configuration
    result = s3client.get_bucket_lifecycle(Bucket=bucket_name)

    pp = pprint.PrettyPrinter()
    pp.pprint(result)

def del_bucket_lifecycle(bucket_name):
    # Call S3 to delete the lifecycle for the given bucket
    print s3client.delete_bucket_lifecycle(Bucket=bucket_name)

endpoint = 'http://{0}'.format(os.environ.get('AWS_HOST'))
# creating a client
s3client = boto3.client('s3',
                        aws_secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY'),
                        aws_access_key_id = os.environ.get('AWS_ACCESS_KEY_ID'),
                        endpoint_url = endpoint)

#print_dict(bucket_lifecycle_list)
put_bucket_lifecycle(bucket_name, bucket_lifecycle_list['demo1'])
get_bucket_lifecycle(bucket_name)
#del_bucket_lifecycle(bucket_name)
