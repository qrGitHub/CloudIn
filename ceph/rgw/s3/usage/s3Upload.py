import boto3
from boto3.s3.transfer import S3Transfer
import sys
import os

s3client = boto3.client('s3', endpoint_url = 'http://223.202.85.133')
transfer = S3Transfer(s3client)

bucket_name = 'boto3Bucket'
filepath = '../trove.tgz'
filename = os.path.basename(filepath)

transfer.upload_file(filepath, bucket_name, filename)
#transfer.download_file(bucket_name, filename, filename)

