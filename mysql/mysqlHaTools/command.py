#!/usr/bin/env python
#-*- coding:utf-8 -*-

import subprocess

def doCommandWithReturnString(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable='/bin/bash', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def doCommand(cmd):
    ret, res = doCommandWithReturnString(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print "%s" % res,

    return ret
