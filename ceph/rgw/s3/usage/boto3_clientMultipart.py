#!/usr/bin/env python

from filechunkio import FileChunkIO
import boto3
import sys, os, math

# creating a client
s3 = boto3.client('s3',
                  aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
                  aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
                  endpoint_url = 'http://172.16.1.107')
bucket_name = 'lyb'
obj_name = 'multipart_test'
file_path = '/root/s3/restore/8M'
file_size = os.stat(file_path).st_size
part_size = 8388608
part_count = int(math.ceil(float(file_size) / part_size))

# Initiate the multipart upload and send the part(s)
mpu = s3.create_multipart_upload(Bucket = bucket_name, Key = obj_name)

print "List parts for {0}".format(mpu['UploadId'])
print s3.list_parts(Bucket=bucket_name,
                    Key=obj_name,
                    MaxParts=100,
                    #PartNumberMarker=123,
                    UploadId = mpu['UploadId'])

parts = []

for i in range(part_count):
    offset = i * part_size
    bytes = min(part_size, file_size - offset)
    with FileChunkIO(file_path, 'r', offset=offset, bytes=bytes) as fp:
        part = s3.upload_part(Bucket = bucket_name, Key = obj_name, PartNumber = i+1,
                       UploadId = mpu['UploadId'], Body = fp.read(bytes))
        parts.append({'PartNumber': i+1, 'ETag': part['ETag']})

# Next, we need to gather information about each part to complete
# the upload. Needed are the part number and ETag.
part_info = {
    'Parts': parts
}

# Now the upload works!
s3.complete_multipart_upload(Bucket = bucket_name, Key = obj_name,
        UploadId = mpu['UploadId'], MultipartUpload = part_info)
