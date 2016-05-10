#!/usr/bin/env python

from mysqlLib import *
import sys, getopt

def usage(cmd):
    print "Usage:\n\tpython {0} --host <host IP>".format(cmd)
    print "Example:\n\tpython {0} --host 1.1.1.1".format(cmd)
    print "\tpython {0} -h".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if None == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'host='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    host = None
    for op, val in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--host'):
            host = val
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(host = host)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    return allowRemoteLogin(host, mysqlUser, mysqlPassword)

mysqlPassword = '111111'
mysqlUser = 'root'

if __name__ == '__main__':
    sys.exit(main(sys.argv))
