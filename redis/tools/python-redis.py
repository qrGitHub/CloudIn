#!/usr/bin/env python
#-*- coding: utf-8 -*-

import redis

host = 'localhost'
port = 6379
pwd = '123456'

r = redis.StrictRedis(host = host, port = port, password = pwd)
r.set('foo', 'bar');
print r.get('foo')
