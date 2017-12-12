import boto.s3.connection
import boto, os

sk = os.environ.get('AWS_SECRET_ACCESS_KEY')
ak = os.environ.get('AWS_ACCESS_KEY_ID')
host = '123.59.184.239'
port = 10004
region = 'debug'

def create_bucket(bucket_name):
    return conn.create_bucket(bucket_name)

def delete_bucket(bucket_name):
    conn.delete_bucket(bucket_name)

def put_bucket_acl(bucket_name, acl):
    bucket = conn.get_bucket(bucket_name)
    bucket.set_acl(acl)

def get_bucket_acl(bucket_name):
    bucket = conn.get_bucket(bucket_name)
    print bucket.get_acl()

def head_bucket(bucket_name):
    """
    Return 200 if the bucket exists and you have permission to access it.
    Otherwise, return responses such as
	    400 - Bad Request
	    403 - Forbidden
	    404 - Not Found
    """
    try:
	conn.head_bucket(bucket_name)
    except boto.exception.S3ResponseError as e:
	return int(e.status)

    return 200

def put_object(bucket_name, object_name, path):
    bucket = conn.get_bucket(bucket_name)
    key = bucket.new_key(object_name)
    return key.set_contents_from_filename(path)

def get_object(bucket_name, object_name, path):
    bucket = conn.get_bucket(bucket_name)
    key = bucket.lookup(object_name)
    key.get_contents_to_filename(path)

def copy_object(bucket_name, object_name, new_name):
    bucket = conn.get_bucket(bucket_name)
    return bucket.copy_key(new_name, bucket_name, object_name)

def delete_object(bucket_name, object_name):
    # delete one or a list of objects
    bucket = conn.get_bucket(bucket_name)
    if isinstance(object_name, list):
        return bucket.delete_keys(object_name)
    else:
        return bucket.delete_key(object_name)

def head_object(bucket_name, object_name):
    # head object
    bucket = conn.get_bucket(bucket_name)
    key = bucket.lookup(object_name)
    print key.name, key.size, key.last_modified

def get_object_acl(bucket_name, object_name):
    bucket = conn.get_bucket(bucket_name)
    print bucket.get_acl(object_name)

def put_object_acl(bucket_name, object_name, acl):
    bucket = conn.get_bucket(bucket_name)
    bucket.set_acl(acl, object_name)

def get_objects4bucket(bucket_name):
    bucket = conn.lookup(bucket_name)
    if None != bucket:
        for key in bucket.list():
            print 'bucket-name:{0}, key-name:{1}'.format(key.bucket.name, key.name)

def get_all_objects():
    for bucket in conn.get_all_buckets():
        print "{name}\t{created}".format(name=bucket.name, created=bucket.creation_date)
        for key in bucket.list():
            print "\t{name}\t{size}\t{modified}".format(name=key.name, size=key.size, modified=key.last_modified)

def get_object_url_v2(bucket_name, object_name):
    print conn.generate_url(86400, 'GET', bucket=bucket_name, key=object_name, query_auth=True)

def get_object_url_v4(bucket_name, object_name):
    if not boto.config.get('s3', 'use-sigv4'):
        boto.config.add_section('s3')
        boto.config.set('s3', 'use-sigv4', 'True')

    # creating a client
    s3 = boto.connect_s3(
            aws_access_key_id=ak,
            aws_secret_access_key=sk,
            is_secure=False, host='{0}:{1}'.format(host, port),
            calling_format=boto.s3.connection.OrdinaryCallingFormat())

    # It seems there is a bug in S3HmacAuthV4Handler::determine_region_name:
    #     It can only read region name from host, when host doestn't contain one,
    #     an exception will be triggered.
    # So we initialize the region name explicitly.
    s3._auth_handler.region_name = region

    print s3.generate_url_sigv4(86400, 'GET', bucket=bucket_name, key=object_name)

# creating a client
conn = boto.connect_s3(
        aws_access_key_id = ak,
        aws_secret_access_key = sk,
        is_secure = False, host = host, port = port,
        calling_format = boto.s3.connection.OrdinaryCallingFormat())

bucket_name = 'lyb'
object_name = 'cloudin-logo.png'

#create_bucket('tst')
#delete_bucket('tst')
#put_bucket_acl(bucket_name, 'private') # private public-read public-read-write authenticated-read
#get_bucket_acl(bucket_name)
#print head_bucket(bucket_name)
#print put_object(bucket_name, 'new_key', '/tmp/del.diff')
#get_object(bucket_name, object_name, '/tmp/download')
#copy_object(bucket_name, object_name, 'new_object')
#print delete_object(bucket_name, 'new_object')
#print delete_object(bucket_name, ['5M', '8M'])
#head_object(bucket_name, object_name)
#put_object_acl(bucket_name, object_name, 'private') # private public-read public-read-write authenticated-read
#get_object_acl(bucket_name, object_name)
#get_objects4bucket(bucket_name)
#get_all_objects()
#get_object_url_v2(bucket_name, object_name)
get_object_url_v4(bucket_name, object_name)
