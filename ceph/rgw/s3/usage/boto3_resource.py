import botocore
import boto3
import sys, os

def test_put_bucket_cors(bucket_name):
    bucket = s3.Bucket(bucket_name)
    cors = bucket.Cors()
    config = {
        'CORSRules': [
            {
                'AllowedMethods': ['GET', 'PUT'],
                'AllowedOrigins': ['*']
            }
        ]
    }

    print cors.put(CORSConfiguration = config)

def test_del_bucket_cors(bucket_name):
    bucket = s3.Bucket(bucket_name)
    cors = bucket.Cors()
    print cors.delete()

s3 = boto3.resource('s3',
        aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
        aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
        endpoint_url='http://172.16.1.4:7480')

bucket_name = 'lyb'
object_name = 'cloudin-logo.png'

#test_put_bucket_cors(bucket_name)
#test_del_bucket_cors(bucket_name)

sys.exit()

# creating a bucket
print s3.create_bucket(Bucket = bucket_name)

# listing owned buckets
for bucket in s3.buckets.all():
    print "Listing owned buckets returns => {0} was created on {1}\n".format(bucket.name, bucket.creation_date)

# getting a bucket
print s3.Bucket(bucket_name)

# deleting a bucket
bucket = s3.Bucket(bucket_name)
response = bucket.delete()
print "Deleting bucket {0} returns => {1}\n".format(bucket_name, response)

# validate whether the bucket exists
exists = True
try:
    s3.meta.client.head_bucket(Bucket = bucket_name)
except botocore.exceptions.ClientError as e:
    # If a client error is thrown, then check that it was a 404 error.
    # If it was a 404 error, then the bucket does not exist.
    error_code = int(e.response['Error']['Code'])
    if error_code == 404:
        exists = False
    else:
        raise
print exists

# Listing all objects for the bucket
bucket = s3.Bucket(bucket_name)
for key in bucket.objects.all():
    print key.key

# bucket cors
bucket = s3.Bucket(bucket_name)
cors = bucket.Cors()

config = {
    'CORSRules': [
        {
            'AllowedMethods': ['GET', 'PUT'],
            'AllowedOrigins': ['*']
        }
    ]
}
print cors.put(CORSConfiguration = config)
print cors.delete()

# get and put bucket acls
bucket = s3.Bucket(bucket_name)
acl = bucket.Acl()
print acl.grants
print acl.put(ACL='public-read')

# put object
obj = s3.Object(bucket_name, object_name)
print obj.put(Body = open('/root/s3/s3Usage/8M', 'rb'))

# delete object
bucket = s3.Bucket('LYB')
objects = [{'Key': 'cmd'}, {'Key': '8M'}]
Delete = {
        'Objects': objects
}
response = bucket.delete_objects(Delete = Delete)
print response

# get object
obj = s3.Object(bucket_name, object_name)
obj.download_file('/tmp/download_from_s3')

# get and put object acls
obj = s3.Object(bucket_name, object_name)
acl = obj.Acl()
print acl.grants
acl.put(ACL='public-read')
print acl.grants

# object copy
copy_source = {
        'Bucket': bucket_name,
        'Key': 'debug_rgw.sh'
}
dst_object_name = 'dst_object'
obj = s3.Object('MYZ', dst_object_name)
obj.copy(copy_source)

#print obj.metadata
#print('Object content length: {}'.format(obj.content_length))
#print('Bucket name: {}'.format(bucket.name))
#print('Object key: {}'.format(obj.key))
#print('Object content length: {}'.format(obj.content_length))
#print('Object body: {}'.format(obj.get()['Body'].read()))
#print('Object last modified: {}'.format(obj.last_modified))

# head object
obj = s3.Object(bucket_name, object_name)
print obj.key, obj.content_length, obj.last_modified
