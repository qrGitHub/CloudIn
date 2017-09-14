#!/usr/bin/env python
#-*- coding:utf-8 -*-

import subprocess
import paramiko
import getopt
import sys
import re
import os

class QrSSHClient(paramiko.SSHClient):
    def exec_command(self, command, bufsize=-1, timeout=None, get_pty=False):
        """
        Add return value.
        """
        chan = self._transport.open_session()
        if get_pty:
            chan.get_pty()
        chan.settimeout(timeout)
        chan.exec_command(command)
        stdin = chan.makefile('wb', bufsize)
        stdout = chan.makefile('r', bufsize)
        stderr = chan.makefile_stderr('r', bufsize)
        status = chan.recv_exit_status()

        return status, stdout, stderr, stdin

def connectRemoteHost(host, port, username, password=""):
    sc = QrSSHClient()
    sc.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    sc.connect(hostname = host,port = port,username = username, password=password)
    return sc

def disconnectRemoteHost(sc):
    sc.close()

def doRemoteCommand(sc, cmd):
    status, stdout, stderr, stdin = sc.exec_command(cmd)
    if status != 0:
        return status, stderr.read()
    else:
        return 0, stdout.read()

def doCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable='/bin/bash', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def usage(cmd):
    print "Usage:\n\tpython {0} --username <user name> --password <password> --port <port> --hostname <host name>".format(cmd)
    print "Example:\n\tpython {0} --username root --password '1qaz2wsx$RFV' --port 22 --hostname 10.1.0.246".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if optionDic[opt] == "":
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def createAuthenticationKey(sc):
    ret, res = doRemoteCommand(sc, 'echo -e "\n\n\n\n" | ssh-keygen')
    if ret != 0:
        print 'run remote command `echo -e "\\n\\n\\n\\n" ssh-keygen` failed(%d)' % ret
        print "%s" % res

    return ret

def readPublicKey():
    cmd = "cat ~/.ssh/id_rsa.pub"
    ret, rsapub = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print "%s" % rsapub

    return ret, rsapub

def sendPublicKey(sc, rsapub):
    rsapub = rsapub.split("\n")[0] # get rid of the trailing newline
    cmd = "echo " + rsapub + " > ~/.ssh/authorized_keys"
    ret, res = doRemoteCommand(sc, cmd)
    if ret != 0:
        print 'run remote command `%s` failed(%d)' % (cmd, ret)
        print "%s" % res

    return ret

def configSSHD(sc):
    sshCfg = "/etc/ssh/sshd_config"

    cmd = "sed -i 's/^[# ]*\(PubkeyAuthentication\) .*$/\\1 yes/' " + sshCfg
    doRemoteCommand(sc, cmd)

    cmd = "sed -i 's/^[# ]*\(RSAAuthentication\) .*$/\\1 yes/' " + sshCfg
    doRemoteCommand(sc, cmd)

    cmd = "echo UseDNS no >> " + sshCfg
    doRemoteCommand(sc, cmd)

    doRemoteCommand(sc, "service ssh restart")

def setPasswordless(hostname, port, username, password):
    sc = connectRemoteHost(hostname, port, username, password)

    ret = createAuthenticationKey(sc)
    if ret != 0:
        print "create authentication key failed"
        return ret

    ret, rsapub = readPublicKey()
    if ret != 0:
        print 'read public key failed'
        return ret

    ret = sendPublicKey(sc, rsapub)
    if ret != 0:
        print 'send public key failed'
        return ret

    #configSSHD(sc)

    disconnectRemoteHost(sc)

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'hostname=', 'port=', 'username=', 'password='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    hostname = port = username = password = ""
    for op, value in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--hostname'):
            hostname = value
        elif op in ('--port'):
            port = value
        elif op in ('--username'):
            username = value
        elif op in ('--password'):
            password = value
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(hostname = hostname, username = username, password = password, port = port)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    ret = setPasswordless(hostname, int(port), username, password)
    return ret

if __name__ == '__main__':
    sys.exit(main(sys.argv))
