#!/usr/bin/env python
#-*- coding:utf-8 -*-

import math, os, sys
import boto, boto.s3.connection
from filechunkio import FileChunkIO
import sys

host = '223.202.85.133'
sk = os.environ.get('AWS_SECRET_ACCESS_KEY')
ak = os.environ.get('AWS_ACCESS_KEY_ID')

#Connect to S3
c = boto.connect_s3(aws_access_key_id = ak, aws_secret_access_key = sk,
                host = host, is_secure = False, calling_format = boto.s3.connection.OrdinaryCallingFormat())

b = c.get_bucket('boto3Bucket')

# Get file info
source_path = '../botoAPI.py'
source_size = os.stat(source_path).st_size

# Use a chunk size of 5 MiB (feel free to change this, must not be smaller than 5MB)
chunk_size = 5242880
chunk_count = int(math.ceil(source_size / float(chunk_size)))

#Create a multipart upload request
print os.path.basename(source_path)
mp = b.initiate_multipart_upload(os.path.basename(source_path))

print 'after initiate'
# Send the file parts, using FileChunkIO to create a file-like object
# that points to a certain byte range within the original file. We
# set bytes to never exceed the original file size.
for i in range(chunk_count):
    offset = chunk_size * i
    print 'offset: ', offset
    length = min(chunk_size, source_size - offset)
    with FileChunkIO(source_path, 'r', offset = offset, bytes = length) as fp:
        ret = mp.upload_part_from_file(fp, part_num = i + 1)
        print ret

# Finish the upload
ret = mp.complete_upload()
print ret
