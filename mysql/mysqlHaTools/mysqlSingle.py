#!/usr/bin/env python

from mysqlLib import *
import sys, getopt

def setupSingleMySQL(host, configFile):
    ret = setupRemoteScripts(host)
    if ret != 0:
        print 'setup remote scripts failed(%d)' % ret
        return ret

    ret = setEncodingWithUtf8(host, configFile)
    if ret != 0:
        print 'set utf8 failed(%d)' % ret
        return ret

    ret = disableDNS(host, configFile)
    if ret != 0:
        print 'disable DNS failed(%d)' % ret
        return ret

    ret = setBindAddress(host, configFile)
    if ret != 0:
        print 'set bind address failed(%d)' % ret
        return ret

    ret = restartMySQL(host)
    if ret != 0:
        print 'restart mysql failed(%d)' % ret
        return ret

    ret = teardownRemoteScripts(host)
    if ret != 0:
        print 'teardown remote scripts failed(%d)' % ret
        return ret

    return 0

def usage(cmd):
    print "Usage:\n\tpython {0} --host <host> [--configFile <config file>]".format(cmd)
    print "Example:\n\tpython {0} --host 1.1.1.1 --configFile /etc/mysql/my.cnf".format(cmd)
    print "\tpython {0} --host 1.1.1.1".format(cmd)
    print "\tpython {0} -h".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if None == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'host=', 'configFile='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    host = configFile = None
    for op, value in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--configFile'):
            configFile = value
        elif op in ('--host'):
            host = value
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(host = host)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    if None == configFile:
        configFile = '/etc/mysql/my.cnf'

    return setupSingleMySQL(host, configFile)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
