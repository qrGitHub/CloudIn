#!/usr/bin/env python
### apt-get install python-paramiko

import paramiko
import re
import sys
import os

hostname=sys.argv[1]
username='root'
password='1qaz2wsx$RFV'
port=22

def connect_remote_host(host, username, password):
    s = paramiko.SSHClient()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname = hostname,port=port,username=username, password=password)
    return s

def disconnect_remote_host(s):
    s.close()
    return

def do_remote_cmd(s, cmd):
    print "Do command: %s" % cmd
    (stdin, stdout, stderr) = s.exec_command(cmd)
    #print stdout.read()
    #result = re.split('\n', stdout.read())
    #result = filter(None, result)
    result = filter(None, re.split('\n', stdout.read()))
    return result

sc = connect_remote_host(hostname, username, password)

result=do_remote_cmd(sc, 'echo -e "\n\n\n\n" | ssh-keygen')

rsa = os.popen("cat ~/.ssh/id_rsa.pub").read()
rsapub = rsa.split("\n")
cmd = "echo " + rsapub[0] + " > ~/.ssh/authorized_keys"
result=do_remote_cmd(sc, cmd)

cmd = "sed 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config > /tmp/mytmp; mv /tmp/mytmp /etc/ssh/sshd_config"
result=do_remote_cmd(sc, cmd)
cmd = "sed 's/PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config > /tmp/mytmp; mv /tmp/mytmp /etc/ssh/sshd_config"
result=do_remote_cmd(sc, cmd)

result=do_remote_cmd(sc, "service ssh restart")

disconnect_remote_host(sc)

