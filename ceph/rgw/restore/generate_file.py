#!/usr/bin/env python
#-*- coding:utf-8 -*-

def to_bytes(data):
    """若输入为unicode， 则转为utf-8编码的bytes；其他则原样返回。"""
    if isinstance(data, unicode):
        return data.encode('utf-8')
    else:
        return data

filename = '8M'

#content = 'a'*4*1024*1024 + 'b'*4*1024*1024 + 'c'*4*1024*1024 + 'd'*3*1024*1024 + 'e'*1024*1024
#content = 'a'*4 + 'b'*4 + 'c'*4 + 'd'*3 + 'e'
content = 'a'*4*1024*1024 + 'b'*4*1024*1024

with open(filename, 'wb') as fp:
    fp.write(to_bytes(content))
