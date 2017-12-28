#!/usr/bin/env python
#-*- coding:utf-8 -*-

from botocore.client import Config
import pprint, sys, os
import boto3

sk = os.environ.get('AWS_SECRET_ACCESS_KEY')
ak = os.environ.get('AWS_ACCESS_KEY_ID')
endpoint = 'http://' + os.environ.get('AWS_HOST')
region = os.environ.get('AWS_REGION')

bucket_cors_list = {
    'demo1': {
        'CORSRules': [
            {
                'AllowedMethods': ['GET', 'PUT'],
                'AllowedOrigins': ['*']
            }
        ]
    },

}

def pretty_printer(content):
    pp = pprint.PrettyPrinter(indent=1, width=80, depth=None, stream=None)
    pp.pprint(content)

def put_bucket_acl(bucket_name, acl):
    return s3client.put_bucket_acl(ACL=acl, Bucket=bucket_name)

def get_bucket_acl(bucket_name):
    result = s3client.get_bucket_acl(Bucket=bucket_name)
    pretty_printer(result)

def put_object_acl(bucket_name, object_name, acl):
    return s3client.put_object_acl(ACL=acl, Bucket=bucket_name, Key=object_name)

def get_object_acl(bucket_name, object_name):
    result = s3client.get_object_acl(Bucket=bucket_name, Key=object_name)
    pretty_printer(result)

def _get_object_url(s3, bucket_name, object_name):
    # Generate the URL to get 'object_name' from 'bucket_name'
    return s3.generate_presigned_url(ClientMethod='get_object',
                                     ExpiresIn=86400,
                                     Params={
                                         'Bucket': bucket_name,
                                         'Key': object_name
                                     })

def get_object_url_v2(bucket_name, object_name):
    s3 = boto3.client('s3',
                      aws_secret_access_key=sk,
                      aws_access_key_id=ak,
                      endpoint_url=endpoint,
                      region_name=region)

    print _get_object_url(s3, bucket_name, object_name)

def get_object_url_v4(bucket_name, object_name):
    # Get the service client with sigv4 configured
    s3 = boto3.client('s3',
                      config=Config(signature_version='s3v4'),
                      aws_secret_access_key=sk,
                      aws_access_key_id=ak,
                      endpoint_url=endpoint,
                      region_name=region)

    print _get_object_url(s3, bucket_name, object_name)

def put_bucket_cors(bucket_name, cors):
    return s3client.put_bucket_cors(Bucket=bucket_name, CORSConfiguration=cors)

def get_bucket_cors(bucket_name):
    result = s3client.get_bucket_cors(Bucket=bucket_name)
    pretty_printer(result)

def del_bucket_cors(bucket_name):
    return s3client.delete_bucket_cors(Bucket=bucket_name)

def create_bucket(bucket_name):
    # creating a bucket
    response = s3client.create_bucket(Bucket=bucket_name,
            CreateBucketConfiguration={
                'LocationConstraint': region
            })
    pretty_printer(response)

def delete_bucket(bucket_name):
    # deleting a bucket
    response = s3client.delete_bucket(Bucket=bucket_name)
    pretty_printer(response)

def get_owned_buckets(bucket_name):
    # listing owned buckets
    response = s3client.list_buckets()
    pretty_printer(response)

def create_object(bucket_name, object_name, content):
    # creating an object
    response = s3client.put_object(Bucket=bucket_name, Key=object_name, Body=content)
    pretty_printer(response)

def delete_object(bucket_name, object_name):
    # Deleting an object
    response = s3client.delete_object(Bucket=bucket_name, Key=object_name)
    pretty_printer(response)

def list_bucket(bucket_name):
    # Listing a bucket's content
    response = s3client.list_objects(Bucket=bucket_name)
    pretty_printer(response)

def set_object_metadata(bucket_name, object_name, metadata):
    # Changing an object's metadata(head object)
    copySrc = '{0}/{1}'.format(bucket_name, object_name)
    response = s3client.copy_object(CopySource=copySrc, Bucket=bucket_name, Key=object_name,
                                    Metadata=metadata, MetadataDirective='REPLACE')
    pretty_printer(response)

def get_object_metadata(bucket_name, object_name):
    response = s3client.head_object(Bucket=bucket_name, Key=object_name)
    pretty_printer(response['Metadata'])

def get_bucket_location(bucket_name):
    result = s3client.get_bucket_location(Bucket=bucket_name)
    pretty_printer(result)

# creating a client
s3client = boto3.client('s3',
                        aws_secret_access_key=sk,
                        aws_access_key_id=ak,
                        endpoint_url=endpoint,
                        region_name=region)

bucket_name = 'myz'
object_name='cloudin-logo.png'

#put_bucket_acl(bucket_name, 'private') # private public-read public-read-write authenticated-read
#get_bucket_acl(bucket_name)
#put_object_acl(bucket_name, object_name, 'private')
#get_object_acl(bucket_name, object_name)

#get_object_url_v2(bucket_name, object_name)
#get_object_url_v4(bucket_name, object_name)

#put_bucket_cors(bucket_name, bucket_cors_list['demo1'])
#get_bucket_cors(bucket_name)
#del_bucket_cors(bucket_name)

#create_bucket(bucket_name)
get_owned_buckets(bucket_name)
#delete_bucket(bucket_name)

#object_name = 'hello.txt'
#create_object(bucket_name, object_name, 'Hello World!')
#list_bucket(bucket_name)
#delete_object(bucket_name, object_name)

#metadata = {
#    'x-amz-meta-datastore': 'RDS',
#    'x-amz-meta-datastore-version': '1.0.1'
#}
#set_object_metadata(bucket_name, object_name, metadata)
#get_object_metadata(bucket_name, object_name)

#get_bucket_location(bucket_name)
