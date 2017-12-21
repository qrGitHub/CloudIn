#!/usr/bin/env python
#-*- coding:utf-8 -*-

from boto.compat import StringIO
import boto.s3.connection
import boto, sys

def compute_md5(string):
    fp = StringIO(string)
    md5 = boto.utils.compute_md5(fp)

    return md5[1]

if len(sys.argv) != 2:
    print "Usage:\n\t{0} <string>".format(sys.argv[0])
    sys.exit(1)

print compute_md5(sys.argv[1])
