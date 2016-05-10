#!/usr/bin/env python

from command import doCommand, doCommandWithReturnString
import re

repPassword = '1234'
repUser = 'repl'

def setEncodingWithUtf8(host, configFile):
    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s client -k default-character-set -v utf8'.format(host, configFile)
    ret = doCommand(cmd)
    if ret != 0:
        return ret

    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysql -k default-character-set -v utf8'.format(host, configFile)
    ret = doCommand(cmd)
    if ret != 0:
        return ret

    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k character_set_server -v utf8'.format(host, configFile)
    ret = doCommand(cmd)
    if ret != 0:
        return ret

    return 0

def disableDNS(host, configFile):
    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k skip-name-resolve'.format(host, configFile)
    return doCommand(cmd)

def setBindAddress(host, configFile):
    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k bind-address -v 0.0.0.0'.format(host, configFile)
    return doCommand(cmd)

def enableBinlog(host, configFile):
    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k log_bin -v MySQL-bin'.format(host, configFile)
    return doCommand(cmd)

def setServerId(host, configFile, ID):
    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k server-id -v {2}'.format(host, configFile, ID)
    return doCommand(cmd)

def setOffsetAndIncrement(host, configFile, offset, increment):
    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k auto_increment_offset -v {2}'.format(host, configFile, offset)
    ret = doCommand(cmd)
    if ret != 0:
        return ret

    cmd = 'ssh {0} python /tmp/sectionKey.py -c {1} -s mysqld -k auto_increment_increment -v {2}'.format(host, configFile, increment)
    return doCommand(cmd)

def restartMySQL(host):
    cmd = 'ssh ' + host + ' service mysql restart'
    return doCommand(cmd)

def setupRemoteScripts(host):
    cmd = 'scp sectionKey.py ' + host + ':/tmp/'
    return doCommand(cmd)

def teardownRemoteScripts(host):
    cmd = 'ssh ' + host + ' rm -f /tmp/sectionKey.py'
    return doCommand(cmd)

def setupMasterConfigFile(host, configFile, ID, offset, increment):
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

    ret = enableBinlog(host, configFile)
    if ret != 0:
        print 'enable binlog failed(%d)' % ret
        return ret

    ret = setServerId(host, configFile, ID)
    if ret != 0:
        print 'set server id to %d failed(%d)' % (ID, ret)
        return ret

    ret = setOffsetAndIncrement(host, configFile, offset, increment)
    if ret != 0:
        print 'set offset(%d) and increment(%d) failed(%d)' % (offset, increment, ID, ret)
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

def setupSlaveConfigFile(host, configFile, ID):
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

    ret = setServerId(host, configFile, ID)
    if ret != 0:
        print 'set server id to %d failed(%d)' % (ID, ret)
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

def createReplicateUser(master, userName, password, slave):
    cmd = '\\"Grant replication slave on *.* to {1}@{0} identified by \'{2}\';\\"'.format(slave, repUser, repPassword)
    cmd = 'ssh {0} "mysql -u{1} -p{2} -e {3}"'.format(master, userName, password, cmd)
    return doCommand(cmd)

def checkReplicateUser(slave, master):
    cmd = 'ssh {0} "mysql -u{1} -p{2} -h{3} -e \\"\\""'.format(slave, repUser, repPassword, master)
    return doCommand(cmd)

def getMasterStatus(master, userName, password):
    cmd = 'ssh {0} "mysql -u{1} -p{2} -s -e \\"show master status;\\""'.format(master, userName, password)
    ret, res = doCommandWithReturnString(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print "%s" % res,
        return ret, "", ""

    resList = re.split(r'\t+', res)
    return 0, resList[0], resList[1]

def allowRemoteLogin(host, userName, password):
    cmd = '\\"update mysql.user set host=\'%\' where user=\'root\' and host=\'localhost\';\\"'
    cmd = 'ssh {0} "mysql -u{1} -p{2} -e {3}"'.format(host, userName, password, cmd)
    ret = doCommand(cmd)
    if ret != 0:
        return ret

    cmd = 'ssh {0} "mysql -u{1} -p{2} -e \\"flush privileges;\\""'.format(host, userName, password)
    ret = doCommand(cmd)
    if ret != 0:
        return ret

    return 0

def connectMasterAndSlave(slave, userName, password, master, logFile, logPos):
    cmd = 'ssh {0} "mysql -u{1} -p{2} -e \\"stop slave;\\""'.format(slave, userName, password)
    ret = doCommand(cmd)
    if ret != 0:
        print 'stop slave falied'
        return ret

    cmd = '\\"change master to master_host=\'{0}\', master_user=\'{1}\', master_password=\'{2}\', master_log_file=\'{3}\', master_log_pos={4};\\"'.format(master, repUser, repPassword, logFile, logPos)
    cmd = 'ssh {0} "mysql -u{1} -p{2} -e {3}"'.format(slave, userName, password, cmd)
    ret = doCommand(cmd)
    if ret != 0:
        print 'change master falied'
        return ret

    cmd = 'ssh {0} "mysql -u{1} -p{2} -e \\"start slave;\\""'.format(slave, userName, password)
    ret = doCommand(cmd)
    if ret != 0:
        print 'start slave falied'
        return ret

    return 0

def setupMasterHost(master, configFile, ID, userName, password, slave, offset = 1, increment = 1):
    ret = setupMasterConfigFile(master, configFile, ID, offset, increment)
    if ret != 0:
        print 'setup master config file failed(%d)' % ret
        return ret

    ret = createReplicateUser(master, userName, password, slave)
    if ret != 0:
        print 'create replicate user failed(%d)' % ret
        return ret

    return 0

def setupSlaveHost(slave, configFile, ID, userName, password, master):
    ret = setupSlaveConfigFile(slave, configFile, ID)
    if ret != 0:
        print 'setup slave config file failed(%d)' % ret
        return ret

    ret = checkReplicateUser(slave, master)
    if ret != 0:
        print 'check replicate user failed(%d)' % ret
        return ret

    ret, logFile, logPos = getMasterStatus(master, userName, password)
    if ret != 0:
        print 'get master status failed(%d)' % ret
        return ret

    ret = connectMasterAndSlave(slave, userName, password, master, logFile, logPos)
    if ret != 0:
        print 'connect master and slave failed(%d)' % ret
        return ret

    return 0
