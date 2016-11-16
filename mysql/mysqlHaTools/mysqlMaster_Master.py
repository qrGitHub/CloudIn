#!/usr/bin/env python
#-*- coding:utf-8 -*-

from mysqlLib import *
import sys, getopt

def setupMaster_SlaveMySQL(master, slave, masterID, slaveID, masterOffset, masterIncrement, configFile, userName, password):
    ret = setupMasterHost(master, configFile, masterID, userName, password, slave, masterOffset, masterIncrement)
    if ret != 0:
        print 'setup master host failed(%d)' % ret
        return ret

    ret = setupSlaveHost(slave, configFile, slaveID, userName, password, master)
    if ret != 0:
        print 'setup slave host failed(%d)' % ret
        return ret

    return 0

def setupMaster_MasterMySQL(master, slave, configFile, userName, password):
    ret = setupMaster_SlaveMySQL(master, slave, 1, 2, 1, 2, configFile, userName, password)
    if ret != 0:
        print 'setup the first master-slave failed(%d)' % ret
        return ret

    setupMaster_SlaveMySQL(slave, master, 2, 1, 2, 2, configFile, userName, password)
    if ret != 0:
        print 'setup the second master-slave failed(%d)' % ret
        return ret

    return 0

def usage(cmd):
    print "Usage:\n\tpython {0} --masterA <masterA IP> --masterB <masterB IP> [--configFile <config file>]".format(cmd)
    print "Example:\n\tpython {0} --masterA 1.1.1.1 --masterB 2.2.2.2 --configFile /etc/mysql/my.cnf".format(cmd)
    print "\tpython {0} --masterA 1.1.1.1 --masterB 2.2.2.2".format(cmd)
    print "\tpython {0} -h".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if None == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'masterA=', 'masterB=', 'configFile='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    masterB = masterA = configFile = None
    for op, val in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--configFile'):
            configFile = val
        elif op in ('--masterA'):
            masterA = val
        elif op in ('--masterB'):
            masterB = val
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(masterB = masterB, masterA = masterA)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    if None == configFile:
        configFile = '/etc/mysql/my.cnf'

    return setupMaster_MasterMySQL(masterA, masterB, configFile, mysqlUser, mysqlPassword)

mysqlPassword = '111111'
mysqlUser = 'root'

if __name__ == '__main__':
    sys.exit(main(sys.argv))
