#!/usr/bin/env python

from filechunkio import FileChunkIO
import boto, boto.s3.connection
import sys, os, math

# creating a client
conn = boto.connect_s3(
        aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
        aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
        is_secure = False, host = '172.16.1.108', port = 7480,
        calling_format = boto.s3.connection.OrdinaryCallingFormat())

bucket_name = 'LYB'
obj_name = 'multipart_test'
file_path = '/root/s3/s3Usage/20M'
file_size = os.stat(file_path).st_size
part_size = 5242880
#part_size = 10485760
part_count = int(math.ceil(float(file_size) / part_size))

bucket = conn.get_bucket(bucket_name)
# Initiate the multipart upload and send the part(s)
mpu = bucket.initiate_multipart_upload(obj_name)

for i in range(part_count):
    offset = i * part_size
    bytes = min(part_size, file_size - offset)
    with FileChunkIO(file_path, 'r', offset=offset, bytes=bytes) as fp:
        print 'offset={0}, bytes={1}'.format(offset, bytes)
        part = mpu.upload_part_from_file(fp, part_num = i+1)
        print part

# Now the upload works!
mpu.complete_upload()
