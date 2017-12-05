#!/usr/bin/env python

from filechunkio import FileChunkIO
import boto, boto.s3.connection
import os, math, sys, time

#obj = boto.connect_s3(aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
#                      aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
#                      is_secure = False, host = '172.16.1.107', port = 80,
#                      calling_format = boto.s3.connection.OrdinaryCallingFormat())
obj = boto.connect_s3(aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
                      aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
                      is_secure = False, host = '172.16.1.103', port = 7480,
                      #is_secure = False, host = '172.16.1.108', port = 7480,
                      calling_format = boto.s3.connection.OrdinaryCallingFormat())
bucket_name = 'lyb'

obj_name = 'multipart_test'
#file_path = '/root/s3/restore/16M.txt'
file_path = '/root/s3/restore/200M'
file_size = os.stat(file_path).st_size
#part_size = 5242880
part_size = 104857600
part_count = int(math.ceil(float(file_size) / part_size))

def find_multipart_uploads(bucket_name, id):
    bucket = obj.get_bucket(bucket_name)

    for mpu in bucket.list_multipart_uploads():
        if mpu.id == id:
            return mpu
    return None

def list_multipart_uploads_for_bucket(bucket_name):
    bucket = obj.get_bucket(bucket_name)

    for mpu in bucket.list_multipart_uploads():
        print vars(mpu)
        for part in mpu.get_all_parts():
            print vars(part)
        mpu.cancel_upload()

def print_key_metadata(bucket_name, obj_name):
    bucket = obj.get_bucket(bucket_name)
    key = bucket.lookup(obj_name)
    print vars(key)

def generate_uncompleted_multipart_upload(bucket_name, obj_name, count):
    bucket = obj.get_bucket(bucket_name)

    for i in range(count):
        print vars(bucket.initiate_multipart_upload(obj_name))

#mpu = find_multipart_uploads(bucket_name, '2~ZsMzSYuwMgIEdCP69z2uYkmwsgc9uzd')
#bucket = obj.get_bucket(bucket_name)
#mpu = bucket.initiate_multipart_upload(obj_name)
#print vars(mpu)
#for i in range(part_count):
#    #if i >= 2:
#    #    continue
#    offset = i * part_size
#    size = min(part_size, file_size - offset)
#    with FileChunkIO(file_path, 'r', offset = offset, bytes = size) as fp:
#        print "begin ", i
#        part = mpu.upload_part_from_file(fp, part_num = i+1)
#        print "end ", i
#        #print part
#
#mpu.complete_upload()

def get_bytes_to_file(key, fp, start, end):             # returns [start, end]
    rangeString = 'bytes={0}-{1}'.format(start, end)    # create byte range as string
    rangeDict = {'Range': rangeString}                  # add this to the dictionary
    key.get_contents_to_file(fp, headers = rangeDict)

def resumable_download(bucket_name, obj_name, file_name, part_size):
    bucket = obj.get_bucket(bucket_name)
    key = bucket.lookup(obj_name)
    fp = open(file_name, 'ab')
    fp.seek(0, os.SEEK_END)

    start = 0
    while start < key.size:
        end = min(start + part_size, key.size) - 1
        if start <= 2048000:
            start = end + 1
            continue

        print "start={0},end={1}".format(start, end)
        get_bytes_to_file(key, fp, start, end)

        start = end + 1

    fp.close()

bucket_name = 'lyb'
obj_name = 'multipart_test'
file_name = '/tmp/download'
part_size = 204800

#resumable_download(bucket_name, obj_name, file_name, part_size)
list_multipart_uploads_for_bucket(bucket_name)
#print_key_metadata(bucket_name, obj_name)
#generate_uncompleted_multipart_upload(bucket_name, obj_name, 1)

#for item in bucket.get_all_multipart_uploads():
#    print type(item.initiator)
#    print type(item._parts)
#    print type(item.initiated)
#    print type(item.key_name)
#    print type(item.bucket)
#    print type(item.Upload)
#    print type(item.is_truncated)
#    print type(item.part_number_marker)
#    print type(item.bucket_name)
#    for key in vars(item):
#        print key
