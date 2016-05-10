#!/usr/bin/env python

from struct import Struct

def writeRecord(record, format, filename):
    '''
    Write a tuple to a binary file.

    '''
    with open(filename, 'wb') as f:
        record_struct = Struct(format)
        f.write(record_struct.pack(*record))

def readRecord(format, filename):
    '''
    Read a tuple from a binary file.

    '''
    try:
        with open(filename, 'rb') as f:
            record_struct = Struct(format)
            record = record_struct.unpack(f.read(record_struct.size))
    except Exception:
        # debug log
        print 'read file[%s] failed' % filename
        record = None

    return record

if __name__ == '__main__':
    record = (10, 10)
    print readRecord('<QQ', '.MYSQLROLLBACKRECORD.DAT')
