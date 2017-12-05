#!/usr/bin/env python
#-*- coding:utf-8 -*-

import boto3
from botocore.client import Config

def generate_url_sample(bucket_name, object_name):
    url = s3client.generate_presigned_url(ClientMethod='get_object',
                                          ExpiresIn = 3600,
                                          Params={
                                              'Bucket': bucket_name,
                                              'Key': object_name
                                          })
    print url


# Get the service client with sigv4 configured
s3client = boto3.client('s3',
                        config=Config(signature_version='s3v4'),
			aws_secret_access_key='9GLb5OtXfImpqUX3LMP4rl2hClRJfk2mzbTEWAlV',
			aws_access_key_id='AKIAJ42XFG7XT2EC6SQA',
                        region_name='ap-northeast-1')

bucket_name = 'myz'
object_name='cloudin-logo.png'
generate_url_sample(bucket_name, object_name)
