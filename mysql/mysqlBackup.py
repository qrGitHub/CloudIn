#!/usr/bin/env python
#-*- coding:utf-8 -*-

import logging, logging.handlers
import subprocess
import os, sys

def initialLogging(logName, logfile):
    logger = logging.getLogger(logName)
    logger.setLevel(logging.DEBUG)

    handler = logging.handlers.RotatingFileHandler(logfile, maxBytes = 1024 * 1024, backupCount = 7)
    handler.setLevel(logging.DEBUG)

    formatter = logging.Formatter('%(asctime)s %(filename)s[%(lineno)d] %(levelname)s %(message)s',
                                            datefmt = '%Y-%m-%d %H:%M:%S')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

def doCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable='/bin/bash', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def getBackupDbList():
    cmd = 'mysql' + mysqlCert + '-s -s -e "show databases;"'
    ret, res = doCommand(cmd)
    if ret != 0:
        logger.error('run `%s` failed:\n%s' % (cmd, res))
        return []

    backupDbList = []
    for db in res.split():
        if db not in excludeDbList:
            backupDbList.append(db)

    return backupDbList

def dumpDatabase(dbList):
    cmd = 'date "+%u"'
    ret, suffix = doCommand(cmd)
    if 0 != ret:
        logger.error('run `{0}` failed:\n{1}'.format(cmd, suffix))
        suffix = 'error'

    successDbList = []
    for db in dbList:
        backupName = db + '.sql.' + suffix.rstrip()
        cmd = "mysqldump{0}{1} > {2}".format(mysqlCert, db, backupName)
        ret, res = doCommand(cmd)
        if 0 != ret:
            logger.error('run `{0}` failed:\n{1}'.format(cmd, res))
        else:
            successDbList.append(backupName)

    return successDbList

def scpDumpFile(dbList):
    failCnt = 0
    for db in dbList:
        cmd = "scp {0} root@{1}:{2}".format(db, backupServerIP, backupPath)
        ret, res = doCommand(cmd)
        if 0 != ret:
            logger.error('run `{0}` failed:\n{1}'.format(cmd, res))
            failCnt += 1

    return failCnt

excludeDbList = ['mysql', 'information_schema', 'performance_schema']
backupPath = '/var/lib/mysqlDisk/backup'
backupServerIP = '10.1.0.149'

mysqlCert = ' -udumper '
logFile = '/var/log/backupMySQL.log'
logName = 'backupMySQL'

if __name__ == '__main__':
    initialLogging(logName, logFile)
    logger = logging.getLogger(logName)

    os.chdir(backupPath)

    logger.debug("Get backup database list Start")
    dbList = getBackupDbList()

    logger.debug("Dump database Start: %s" % dbList)
    successDbList = dumpDatabase(dbList)

    logger.debug("Scp dumpFile Start: %s" % successDbList)
    ret = scpDumpFile(successDbList)
    logger.debug("Scp dumpFile End[%d]" % ret)

    sys.exit(ret)
