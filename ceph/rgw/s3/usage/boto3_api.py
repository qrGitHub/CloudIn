#!/usr/bin/env python
#-*- coding:utf-8 -*-

import boto3
import sys

# creating a client
s3client = boto3.client('s3',
			aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
			aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
			endpoint_url = 'http://172.16.1.107')

bucket_name = 'LYB'
print s3client.get_bucket_location(Bucket = bucket_name)
sys.exit()

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

# Get object url
print s3client.generate_presigned_url('get_object', Params = {'Bucket': 'LYB', 'Key': 'botoAPI.py'})
