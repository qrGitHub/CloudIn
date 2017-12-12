#!/usr/bin/env python
#-*- coding:utf-8 -*-

from botocore.client import Config
import pprint, sys, os
import boto3

sk = os.environ.get('AWS_SECRET_ACCESS_KEY')
ak = os.environ.get('AWS_ACCESS_KEY_ID')
endpoint = 'http://172.16.1.4:7480'

def put_bucket_acl(bucket_name, acl):
    return s3client.put_bucket_acl(ACL=acl, Bucket=bucket_name)

def get_bucket_acl(bucket_name):
    result = s3client.get_bucket_acl(Bucket=bucket_name)
    pp = pprint.PrettyPrinter(indent=1, width=80, depth=None, stream=None)
    pp.pprint(result)

def put_object_acl(bucket_name, object_name, acl):
    return s3client.put_object_acl(ACL=acl, Bucket=bucket_name, Key=object_name)

def get_object_acl(bucket_name, object_name):
    result = s3client.get_object_acl(Bucket=bucket_name, Key=object_name)
    pp = pprint.PrettyPrinter(indent=1, width=80, depth=None, stream=None)
    pp.pprint(result)

def get_object_url(s3, bucket_name, object_name):
    # Generate the URL to get 'object_name' from 'bucket_name'
    return s3.generate_presigned_url(ClientMethod='get_object',
                                     ExpiresIn = 86400,
                                     Params = {
                                         'Bucket': bucket_name,
                                         'Key': object_name
                                     })

def get_object_url_v2(bucket_name, object_name):
    s3 = boto3.client('s3',
                      aws_secret_access_key = sk,
                      aws_access_key_id = ak,
                      endpoint_url = 'http://123.59.184.239:10004')

    print get_object_url(s3, bucket_name, object_name)

def get_object_url_v4(bucket_name, object_name):
    # Get the service client with sigv4 configured
    s3 = boto3.client('s3',
                      config=Config(signature_version='s3v4'),
                      aws_secret_access_key = sk,
                      aws_access_key_id = ak,
                      endpoint_url = 'http://123.59.184.239:10004')

    print get_object_url(s3, bucket_name, object_name)

# creating a client
s3client = boto3.client('s3',
                        aws_secret_access_key = sk,
                        aws_access_key_id = ak,
                        endpoint_url = endpoint)

bucket_name = 'lyb'
object_name='cloudin-logo.png'
#put_bucket_acl(bucket_name, 'private') # private public-read public-read-write authenticated-read
get_object_url_v2(bucket_name, object_name)
#get_object_url_v4(bucket_name, object_name)

#get_bucket_acl(bucket_name)
#put_object_acl(bucket_name, object_name, 'private')
#get_object_acl(bucket_name, object_name)

sys.exit()

print s3client.get_bucket_location(Bucket = bucket_name)

# creating a bucket
response = s3client.create_bucket(Bucket = bucket_name)
print "Creating bucket {0} returns => {1}\n".format(bucket_name, response)

# listing owned buckets
response = s3client.list_buckets()
for bucket in response['Buckets']:
    print "Listing owned buckets returns => {0} was created on {1}\n".format(bucket['Name'], bucket['CreationDate'])

# creating an object
object_key = 'hello.txt'
response = s3client.put_object(Bucket = bucket_name, Key = object_key, Body = 'Hello World!')
print "Creating object {0} returns => {1}\n".format(object_key, response)

# Listing a bucket's content
response = s3client.list_objects(Bucket = bucket_name)
for obj in response['Contents']:
    print "Listing a bucket's content returns => {0}\t{1}\t{2}\n".format(obj['Key'], obj['Size'], obj['LastModified'])

# Changing an object's metadata(head object)
metadata = {'x-amz-meta-datastore': 'qr', 'x-amz-meta-datastore-version': '1.0.1'}
copySrc = '{0}/{1}'.format(bucket_name, object_key)
response = s3client.copy_object(Bucket = bucket_name, CopySource = copySrc, Key = object_key, Metadata = metadata, MetadataDirective = 'REPLACE')
print "Changing metadata of object {0} returns => {1}\n".format(object_key, response)

# Deleting an object
response = s3client.delete_object(Bucket = bucket_name, Key = object_key)
print "Deleting object {0} returns => {1}\n".format(object_key, response)

# deleting a bucket
response = s3client.delete_bucket(Bucket = bucket_name)
print "Deleting bucket {0} returns => {1}\n".format(bucket_name, response)
