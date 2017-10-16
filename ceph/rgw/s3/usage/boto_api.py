import boto
import boto.s3.connection
import sys

# creating a client
conn = boto.connect_s3(
        aws_access_key_id = '9I8980NI0DE7GMBHR4AL',
        aws_secret_access_key = 'CoDeyVzuRtZD28T8tJpMYStgGQPG4spRT5ioT4b2',
        #is_secure = False, host = '172.16.1.107', port = 80,
        is_secure = False, host = '172.16.1.103', port = 7480,
        calling_format = boto.s3.connection.OrdinaryCallingFormat())

bucket_name = 'LYB'
obj_name = 'botoAPI.py'

print conn.lookup(bucket_name)
#try:
#    print conn.head_bucket(bucket_name)
#except boto.exception.S3ResponseError as e:
#    print e.status

#bucket = conn.get_bucket(bucket_name)
#key = bucket.lookup('botoAPI.py')
#print key.generate_url(0, query_auth=True, force_http=True)

sys.exit()

#bucket_name = 'bucket0414'
#print('Creating new bucket with name: {}'.format(bucket_name))
#bucket = conn.create_bucket(bucket_name)
#conn.delete_bucket(bucket_name)
#conn.delete_bucket('LYB')

#bucket = conn.lookup(bucket_name)
#if None != bucket:
#    for key in bucket.list():
#        print 'bucket-name:{0}, key-name:{1}'.format(key.bucket.name, key.name)

#filename = 'install.sh'
#key = bucket.new_key(filename)
#key.set_contents_from_filename(filename)

for bucket in conn.get_all_buckets():
    print "{name}\t{created}".format(name = bucket.name, created = bucket.creation_date)
    #conn.delete_bucket('LYB')
    for key in bucket.list():
        print "{name}\t{size}\t{modified}".format(name = key.name, size = key.size, modified = key.last_modified)

# put object
bucket = conn.get_bucket(bucket_name)
key = bucket.new_key(obj_name)
key.set_contents_from_filename('/root/s3/s3Usage/boto3Api.py')

# delete object & objects
bucket = conn.get_bucket(bucket_name)
print bucket.delete_key(obj_name)
print bucket.delete_keys(['5M', '8M'])

# copy object
bucket = conn.get_bucket(bucket_name)
print bucket.copy_key("new_key_name", bucket_name, "botoAPI.py")

# get object
bucket = conn.get_bucket(bucket_name)
key = bucket.lookup(obj_name)
print key.get_contents_to_filename('/root/s3/s3Usage/download')

#bucket = conn.get_bucket(bucket_name)
#key = bucket.lookup('botoAPI.py')
#print key.generate_url(0, query_auth=True, force_http=True)

# head object
bucket = conn.get_bucket(bucket_name)
key = bucket.lookup(obj_name)
print key.name, key.last_modified, key.size

# get and set object acls
bucket = conn.get_bucket(bucket_name)
print bucket.get_acl(obj_name)
print bucket.set_acl('public-read', obj_name)
print bucket.get_acl(obj_name)
