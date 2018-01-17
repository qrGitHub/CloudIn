#!/usr/bin/env python

import getopt, time, sys, re, os
import multiprocessing
import subprocess

def usage(name):
    print "Usage:\n\tpython {0} --cmdSet <cmd set> [--host <host>] ".format(name)
    print 'Example:\n\tpython {0} --cmdSet "ls, pwd" --host 127.0.0.1'.format(name)
    print '\tpython {0} --cmdSet "uname -a"'.format(name)
    print '\tpython {0} --help'.format(name)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if "" == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def doCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable='/bin/bash', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def prepareLogDirectory(prefix):
    now = time.strftime("%Y%m%d%H%M%S", time.localtime())
    logDir = os.path.join(prefix, now)
    os.makedirs(logDir)

    return logDir

def getValueOfOption(cmd, opt):
    matchObj = re.match(r'.*{0}=([^ ]+) '.format(opt), cmd)
    if matchObj:
        return 0, matchObj.group(1)
    else:
        return 1, ''

def basename(path):
    '''The path may not exist'''
    matchObj = re.match(r'.*/([^/]+)$', path)
    if matchObj:
        return 0, matchObj.group(1)
    else:
        return 1, ''

def getLogfileName(cmd):
    ret, filePath = getValueOfOption(cmd, '-filename')
    if ret != 0:
        sys.stderr.write('Get value of -filename failed[%d]\n' % ret)
        return ''

    ret, fileName = basename(filePath)
    if ret != 0:
        sys.stderr.write('Get base name of %s failed[%d]\n' % (filePath, ret))
        return ''

    ret, blockSize = getValueOfOption(cmd, '-bs')
    if ret != 0:
        sys.stderr.write('Get value of -bs failed[%d]\n' % ret)
        return ''

    ret, rwMode = getValueOfOption(cmd, '-rw')
    if ret != 0:
        sys.stderr.write('Get value of -rw failed[%d]\n' % ret)
        return ''

    return '{0}_{1}_{2}.log'.format(fileName, blockSize, rwMode)

def writeToFile(filename, mode, *contents):
    with open(filename, mode) as f:
        for item in contents:
            f.write(item + '\n')

def flushCaches(prefix):
    cmd = '{0}"sync; echo 3 > /proc/sys/vm/drop_caches"'.format(prefix)
    doCommand(cmd)

def doCommandSetWithPrefix(cmdSet, prefix, logDir):
    for cmd in cmdSet.split(','):
        if '' == cmd:
            continue

        flushCaches(prefix)

        cmd = prefix + cmd.strip()
        ret, res = doCommand(cmd)
        if ret != 0:
            sys.stderr.write('Run command `%s` failed\n' % cmd)
            return ret

        logFile = getLogfileName(cmd)
        if logFile != '':
            writeToFile(os.path.join(logDir, logFile), 'w', cmd, res)
        else:
            print cmd
            print res,

    return 0

def doCommandSetOnHost(cmdSet, host):
    logDir = prepareLogDirectory(host)

    if '' != host:
        prefix = 'ssh {0} '.format(host)
    else:
        prefix = ''

    return doCommandSetWithPrefix(cmdSet, prefix, logDir)

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'host=', 'cmdSet='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    host = cmdSet = ""
    for op, value in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--host'):
            host = value
        elif op in ('--cmdSet'):
            cmdSet = value
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(cmdSet = cmdSet)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    return doCommandSetOnHost(cmdSet, host)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
