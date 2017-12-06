import boto
import boto.s3.connection
import sys, os

def put_bucket_acl(bucket_name, **kwargs):
    bucket = conn.get_bucket(bucket_name)
    return bucket.set_acl(**kwargs)

def get_bucket_acl(bucket_name):
    bucket = conn.get_bucket(bucket_name)
    return bucket.get_acl()

def test_bucket_acl(bucket_name):
    acl = sys.argv[1] if len(sys.argv) == 2 else 'private'
    put_bucket_acl(bucket_name, acl_or_str = acl)

# creating a client
conn = boto.connect_s3(
        aws_access_key_id = os.environ.get('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY'),
        is_secure = False, host = '172.16.1.4', port = 7480,
        calling_format = boto.s3.connection.OrdinaryCallingFormat())

bucket_name = 'lyb'
obj_name = 'cloudin-logo.png'

#bucket = conn.get_bucket(bucket_name)

#test_bucket_acl(bucket_name)
#put_bucket_acl(bucket_name, acl_or_str = 'private') # public-read private
#print get_bucket_acl(bucket_name)

print conn.generate_url(expires_in=86400, method='GET', bucket=bucket_name, key=obj_name, query_auth=True)
#print bucket.set_acl('public-read', obj_name)
#print bucket.get_acl(obj_name)
