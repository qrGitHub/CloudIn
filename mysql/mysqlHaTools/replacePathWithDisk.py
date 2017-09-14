#!/usr/bin/env python
#-*- coding:utf-8 -*-

from command import doCommand, doCommandWithReturnString
import os, sys, getopt

def usage(cmd):
    print "Usage:\n\tpython {0} --path <absolute path> --device <device path>".format(cmd)
    print "Example:\n\tpython {0} --path /mnt --device /dev/vdb".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if None == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def formatDevice(device):
    cmd = 'mkfs.ext4 ' + device
    return doCommand(cmd)

def moveFilesTemporarily(path):
    tmpDir = '/tmp/.tempDir'
    suffix = 0
    while os.path.exists(tmpDir + str(suffix)):
        suffix += 1
    tmpDir += str(suffix)

    cmd = 'mkdir ' + tmpDir
    ret = doCommand(cmd)
    if 0 != ret:
        return ret, ''

    cmd = 'cp -a {0}/* {1}/'.format(path, tmpDir)
    ret = doCommand(cmd)
    if 0 != ret:
        return ret, ''

    cmd = 'rm -rf {0}/*'.format(path)
    ret = doCommand(cmd)
    return ret, tmpDir

def mountDevice(device, path):
    cmd = 'mount {0} {1}'.format(device, path)
    return doCommand(cmd)

def moveFilesPermanently(tmpDir, path):
    cmd = 'cp -a {0}/* {1}/'.format(tmpDir, path)
    ret = doCommand(cmd)
    if 0 != ret:
        return ret

    cmd = 'rm -rf {0}'.format(tmpDir)
    ret = doCommand(cmd)
    return ret

def analyzeBlkidRes(res):
    itemList = res.split()
    itemList[0] = itemList[0].rstrip(':')
    itemList[1] = itemList[1].split('=')[1].strip('"')
    itemList[2] = itemList[2].split('=')[1].strip('"')

    return itemList

def updateFstab(device):
    cmd = 'blkid ' + device
    ret, res = doCommandWithReturnString(cmd)
    if 0 != ret:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print "%s" % res,
        return ret

    itemList = analyzeBlkidRes(res)
    line = 'UUID={0} {1} {2} defaults 0 0'.format(itemList[1], itemList[0], itemList[2])
    cmd = 'echo "{0}" >> /etc/fstab'.format(line)
    ret = doCommand(cmd)
    if 0 != ret:
        return ret

    return 0

def replacePathWithDisk(path, device):
    ret = formatDevice(device)
    if 0 != ret:
        print 'format device {0} failed({1})'.format(device, ret)
        return ret

    ret, tmpDir = moveFilesTemporarily(path)
    if 0 != ret:
        print 'mv {0} temporarily failed({1})'.format(path, ret)
        return ret

    ret = mountDevice(device, path)
    if 0 != ret:
        print 'mount {0} to {1} failed({2})'.format(device, path, ret)
        return ret

    ret = moveFilesPermanently(tmpDir, path)
    if 0 != ret:
        print 'mv {0} to {1} failed({2})'.format(tmpDir, path, ret)
        return ret

    ret = updateFstab(device)
    if 0 != ret:
        print 'update fstab failed({0})'.format(ret)
        return ret

    return 0

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'hp:d:', ['help', 'path=', 'device='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    path = device = None
    for op, value in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('-p', '--path'):
            path = value.rstrip('/')
        elif op in ('-d', '--device'):
            device = value
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(path = path, device = device)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    return replacePathWithDisk(path, device)

if '__main__' == __name__:
    sys.exit(main(sys.argv))
