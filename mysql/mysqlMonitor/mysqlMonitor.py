#!/usr/bin/env python

from binaryFile import writeRecord, readRecord
import re, sys, time
import subprocess

# the configurations for this tool
monitorPassword = '111111'
monitorUsername = 'root'

def doLocalCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable = '/bin/bash', shell = True, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read().strip('\n')
    else:
        return 0, process.stdout.read().strip('\n')

class mysqlMonitor:
    def __init__(self):
        self.credential = '-u{0} -p{1}'.format(monitorUsername, monitorPassword)
        self.fileName = {
                        'Com_rollback': '.MYSQLROLLBACKRECORD.DAT',
                        'Com_commit': '.MYSQLCOMMITRECORD.DAT',
                        'Select_scan': '.MYSQLSCANRECORD.DAT',
                        'Queries': '.MYSQLQUERIESRECORD.DAT',
                        'qps': '.MYSQLQPSRECORD.DAT',
                        'tps': '.MYSQLTPSRECORD.DAT',
                        'iops': '.IOPSRECORD.DAT',
                        }
        self.device = '/dev/vdb'

    def getGlobalStatus(self, statusName):
        mysqlCmd = 'show global status like \'{0}\';'.format(statusName)
        cmd = 'mysql {0} -s -s -e "{1}"'.format(self.credential, mysqlCmd)

        ret, res = doLocalCommand(cmd)
        if ret != 0:
            sys.stderr.write('Run command `%s` failed[%d]\n' % (cmd, ret))
            return None

        matchObj = re.match(r'^[^\s]+\s+(.*)$', res)
        if matchObj:
            res = matchObj.group(1)
        else:
            sys.stderr.write('Split line[%s] failed\n' % res)
            return None

        return res

    def createRecord(self, statusName):
        num = self.getGlobalStatus(statusName)
        if None == num:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        currTime = int(time.time())
        return int(num), currTime

    def getIntervalNum(self, statusName):
        record = self.createRecord(statusName)
        if None == record:
            sys.stderr.write('create record for %s failed\n' % statusName)
            return None

        prevRecord = readRecord('<QQ', self.fileName[statusName])
        writeRecord(record, '<QQ', self.fileName[statusName])
        if None == prevRecord:
            return 0

        return record[0] - prevRecord[0]

    def getQueriesNum(self):
        '''
        Name: Queries
        Unit: the number of Queries

        '''
        return self.getIntervalNum('Queries')

    def getCommitNum(self):
        '''
        Name: transCommit
        Unit: the number of Com_commit

        '''
        return self.getIntervalNum('Com_commit')

    def getRollbackNum(self):
        '''
        Name: transRollback
        Unit: the number of Com_rollback

        '''
        return self.getIntervalNum('Com_rollback')

    def getScanNum(self):
        '''
        Name: scanNum
        Unit: the number of Select_scan

        '''
        return self.getIntervalNum('Select_scan')

    def createTransRecord(self):
        statusName = 'Com_insert'
        insertCount = self.getGlobalStatus(statusName)
        if None == insertCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        statusName = 'Com_update'
        updateCount = self.getGlobalStatus(statusName)
        if None == updateCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        statusName = 'Com_delete'
        deleteCount = self.getGlobalStatus(statusName)
        if None == deleteCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        totalCount = int(insertCount) + int(updateCount) + int(deleteCount)
        currTime = int(time.time())
        return totalCount, currTime

    def getTPS(self):
        '''
        Name: TPS
        Unit: transaction per second

        '''
        record = self.createTransRecord()
        if None == record:
            sys.stderr.write('create transaction record failed\n')
            return None

        prevRecord = readRecord('<QQ', self.fileName['tps'])
        writeRecord(record, '<QQ', self.fileName['tps'])
        if None == prevRecord:
            return 0

        numDiff = record[0] - prevRecord[0]
        timeDiff = record[1] - prevRecord[1]
        if 0 != timeDiff:
            tps = 1.0 * numDiff / timeDiff
        else:
            tps = 0

        return tps

    def createQueryRecord(self):
        statusName = 'Com_select'
        selectCount = self.getGlobalStatus(statusName)
        if None == selectCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        statusName = 'Com_insert'
        insertCount = self.getGlobalStatus(statusName)
        if None == insertCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        statusName = 'Com_update'
        updateCount = self.getGlobalStatus(statusName)
        if None == updateCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        statusName = 'Com_delete'
        deleteCount = self.getGlobalStatus(statusName)
        if None == deleteCount:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        totalCount = int(selectCount) + int(insertCount) + int(updateCount) + int(deleteCount)
        currTime = int(time.time())
        return totalCount, currTime

    def getQPS(self):
        '''
        Name: QPS
        Unit: queries per second

        '''
        record = self.createQueryRecord()
        if None == record:
            sys.stderr.write('create query record failed\n')
            return None

        prevRecord = readRecord('<QQ', self.fileName['qps'])
        writeRecord(record, '<QQ', self.fileName['qps'])
        if None == prevRecord:
            return 0

        numDiff = record[0] - prevRecord[0]
        timeDiff = record[1] - prevRecord[1]
        if 0 != timeDiff:
            qps = 1.0 * numDiff / timeDiff
        else:
            qps = 0

        return qps

    def getConnectionNum(self):
        '''
        Name: currentConnectionNum

        '''
        statusName = 'Threads_connected'
        ret = self.getGlobalStatus(statusName)
        if None == ret:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        return ret

    def getActiveConnectionNum(self):
        '''
        Name: activeConnectionNum

        '''
        statusName = 'Threads_running'
        ret = self.getGlobalStatus(statusName)
        if None == ret:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        return ret

    def getInnodbFreeBufferSize(self):
        '''
        Name: innodbFreeBufferSize
        Unit: MB

        '''
        statusName = 'Innodb_buffer_pool_pages_free'
        ret = self.getGlobalStatus(statusName)
        if None == ret:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None
        size = int(ret)

        return size * 16 / 1024

    def getInnodbHitratio(self):
        '''
        Name: innodbBufferReadHitratio
        Unit: %

        '''
        statusName = 'Innodb_buffer_pool_reads'
        ret = self.getGlobalStatus(statusName)
        if None == ret:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None
        buffer_pool_reads = int(ret)

        statusName = 'Innodb_buffer_pool_read_requests'
        ret = self.getGlobalStatus(statusName)
        if None == ret:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None
        buffer_pool_read_requests = int(ret)

        if 0 == buffer_pool_read_requests:
            ratio = 0
        else:
            ratio = round(100 - (100.0 * buffer_pool_reads / buffer_pool_read_requests), 2)
        return ratio

    def getSlowqueries(self):
        '''
        Name: slowqueries
        Unit: the number of slow queries
        Note: For internal use

        '''
        statusName = 'Slow_queries'
        num = self.getGlobalStatus(statusName)
        if None == num:
            sys.stderr.write('Get global status %s failed\n' % statusName)
            return None

        return int(num)

    def grepSlaveStatus(self, pattern):
        mysqlCmd = 'show slave status\G;'
        cmd = 'mysql {0} -e "{1}"'.format(self.credential, mysqlCmd)
        cmd = '{0} | grep -i "{1}"'.format(cmd, pattern)

        ret, res = doLocalCommand(cmd)
        if ret != 0:
            return None

        return res.split(':')[1].strip()

    def secondsBehindMaster(self):
        '''
        Name: secondsBehindMaster
        Unit: second
        Note: For internal use

        '''
        ret = self.grepSlaveStatus('Seconds_Behind_Master:')
        if ret != None:
            ret = int(ret)

        return ret

    def ioThreadStatus(self):
        '''
        Name: ioThread
        Note: For internal use

        '''
        ret = self.grepSlaveStatus('Slave_IO_Running:')
        if ret != None:
            if 'Yes' == ret:
                ret = 1
            else:
                ret = 0

        return ret

    def sqlThreadStatus(self):
        '''
        Name: sqlThread
        Note: For internal use

        '''
        ret = self.grepSlaveStatus('Slave_SQL_Running:')
        if ret != None:
            if 'Yes' == ret:
                ret = 1
            else:
                ret = 0

        return ret

    def deviceName2No(self, name):
        cmd = 'ls -l ' + name
        ret, res = doLocalCommand(cmd)
        if ret != 0:
            sys.stderr.write('Run command `%s` failed[%d]\n' % (cmd, ret))
            sys.stderr.write('%s\n' % res)
            return ret, (None, None)

        matchObj = re.match(r'^.*\s(\d+),\s(\d+)\s', res)
        if matchObj:
            major = matchObj.group(1)
            minor = matchObj.group(2)
        else:
            sys.stderr.write('match device num from "%s" failed\n' % res)
            return 1, (None, None)

        return 0, (major, minor)

    def getDiskstats(self, major, minor):
        cmd = 'cat /proc/diskstats | grep "{0}\s\+{1}"'.format(major, minor)
        ret, res = doLocalCommand(cmd)
        if ret != 0:
            sys.stderr.write('Run command `%s` failed[%d]\n' % (cmd, ret))
            sys.stderr.write('%s\n' % res)
            return ret, None

        return 0, res

    def getDiskios(self, major, minor):
        ret, res = self.getDiskstats(major, minor)
        if ret != 0:
            sys.stderr.write('Get disk stats failed[%d]\n' % ret)
            return None

        res = res.split()
        return (int(res[3]), int(res[7]))

    def createIORecord(self):
        ret, (major, minor) = self.deviceName2No(self.device)
        if 0 != ret:
            sys.stderr.write('Transfer device name(%s) to device no. failed\n' % self.device)
            return None

        ios = self.getDiskios(major, minor)
        if None == ios:
            sys.stderr.write('Get disk reads and writes failed\n')
            return None

        currTime = int(time.time())
        return ios[0], ios[1], currTime

    def getIOPS(self):
        '''
        Name: IOPS
        Unit: reads/writes number per second

        '''
        record = self.createIORecord()
        if None == record:
            sys.stderr.write('create IO record failed\n')
            return None

        prevRecord = readRecord('<QQQ', self.fileName['iops'])
        writeRecord(record, '<QQQ', self.fileName['iops'])
        if None == prevRecord:
            return (0, 0)

        readsDiff = record[0] - prevRecord[0]
        writesDiff = record[1] - prevRecord[1]
        timeDiff = record[2] - prevRecord[2]
        if 0 != timeDiff:
            rps = 1.0 * readsDiff / timeDiff
            wps = 1.0 * writesDiff / timeDiff
        else:
            rps = wps = 0

        return (rps, wps)

if __name__ == '__main__':
    obj = mysqlMonitor()
    #print obj.getConnectionNum()
    #print obj.getActiveConnectionNum()
    #print obj.getInnodbFreeBufferSize()
    #print obj.getInnodbHitratio()
    #print obj.getQPS()
    #print obj.getTPS()
    #print obj.getScanNum()
    #print obj.getRollbackNum()
    #print obj.getCommitNum()
    #print obj.getQueriesNum()
    #print obj.getSlowqueries()
    #print obj.secondsBehindMaster()
    #print obj.sqlThreadStatus()
    #print obj.ioThreadStatus()
    print obj.getIOPS()
