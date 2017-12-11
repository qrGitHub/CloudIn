#!/usr/bin/env python
#-*- coding:utf-8 -*-

import boto3, os

# creating a client
s3client = boto3.client('s3',
			aws_secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY'),
			aws_access_key_id = os.environ.get('AWS_ACCESS_KEY_ID'),
                        endpoint_url = 'http://123.59.184.136:80')

# creating a bucket
bucket_name = 'DEMO'
response = s3client.create_bucket(Bucket = bucket_name)
print "Creating bucket {0} returns => {1}\n". \
        format(bucket_name, response['ResponseMetadata']['HTTPStatusCode'])

# listing owned buckets
response = s3client.list_buckets()
for bucket in response['Buckets']:
    print "Listing owned buckets returns => {0} was created on {1}". \
            format(bucket['Name'], bucket['CreationDate'])

# creating an object
object_key = 'hello.txt'
response = s3client.put_object(Bucket = bucket_name, Key = object_key, Body = 'Hello World!')
print "\nCreating object {0} returns => {1}\n". \
        format(object_key, response['ResponseMetadata']['HTTPStatusCode'])

# Listing a bucket's content
response = s3client.list_objects(Bucket = bucket_name)
for obj in response['Contents']:
    print "Listing a bucket's content returns => {0}\t{1}\t{2}\n". \
            format(obj['Key'], obj['Size'], obj['LastModified'])

# Deleting an object
response = s3client.delete_object(Bucket = bucket_name, Key = object_key)
print "Deleting object {0} returns => {1}\n". \
        format(object_key, response['ResponseMetadata']['HTTPStatusCode'])

# deleting a bucket
response = s3client.delete_bucket(Bucket = bucket_name)
print "Deleting bucket {0} returns => {1}". \
        format(bucket_name, response['ResponseMetadata']['HTTPStatusCode'])
