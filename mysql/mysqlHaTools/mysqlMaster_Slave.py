#!/usr/bin/env python

from mysqlLib import *
import sys, getopt

def setupMaster_SlaveMySQL(master, slave, configFile, userName, password):
    ret = setupMasterHost(master, configFile, 1, userName, password, slave)
    if ret != 0:
        print 'setup master host failed(%d)' % ret
        return ret

    ret = setupSlaveHost(slave, configFile, 2, userName, password, master)
    if ret != 0:
        print 'setup slave host failed(%d)' % ret
        return ret

    return 0

def usage(cmd):
    print "Usage:\n\tpython {0} --master <master IP> --slave <slave IP> [--configFile <config file>]".format(cmd)
    print "Example:\n\tpython {0} --master 1.1.1.1 --slave 2.2.2.2 --configFile /etc/mysql/my.cnf".format(cmd)
    print "\tpython {0} --master 1.1.1.1 --slave 2.2.2.2".format(cmd)
    print "\tpython {0} -h".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if None == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'slave=', 'master=', 'configFile='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    slave = master = configFile = None
    for op, val in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--configFile'):
            configFile = val
        elif op in ('--master'):
            master = val
        elif op in ('--slave'):
            slave = val
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(slave = slave, master = master)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    if None == configFile:
        configFile = '/etc/mysql/my.cnf'

    return setupMaster_SlaveMySQL(master, slave, configFile, mysqlUser, mysqlPassword)

mysqlPassword = '111111'
mysqlUser = 'root'

if __name__ == '__main__':
    sys.exit(main(sys.argv))
