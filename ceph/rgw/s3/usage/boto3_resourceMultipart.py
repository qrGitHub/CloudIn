#!/usr/bin/env python

from filechunkio import FileChunkIO
import boto3, botocore
import sys, os, math

s3 = boto3.resource('s3', endpoint_url = 'http://172.16.1.107')
bucket_name = 'LYB'
obj_name = 'multipart_test'
file_path = '/root/s3/s3Usage/20M'
file_size = os.stat(file_path).st_size
part_size = 5242880
part_count = int(math.ceil(float(file_size) / part_size))

#bucket = s3.Bucket(bucket_name)
#for item in bucket.multipart_uploads.all():
#    print item
#    print item.abort()
#    break
#
#sys.exit()

obj = s3.Object(bucket_name, obj_name)

mpu = obj.initiate_multipart_upload()

parts = []

for i in range(part_count):
    offset = i * part_size
    size = min(part_size, file_size - offset)
    with FileChunkIO(file_path, 'r', offset = offset, bytes = size) as fp:
        part = mpu.Part(i+1)
        response = part.upload(Body = fp.read(size))
        parts.append({'PartNumber': i+1, 'ETag': response['ETag']})

# Next, we need to gather information about each part to complete
# the upload. Needed are the part number and ETag.
part_info = {
    'Parts': parts
}

#mpu.complete(MultipartUpload = part_info)
mpu.abort()
