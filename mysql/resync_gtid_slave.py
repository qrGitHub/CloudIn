#!/usr/bin/env python
#-*- coding:utf-8 -*-

import subprocess
import argparse
import sys

def doCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable='/bin/bash', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def get_purge_cmd(args):
    cmd  = "stop slave; "
    cmd += "reset slave; "
    cmd += "reset master; "
    cmd += "set global gtid_purged = '{0}:{1}-{2}'; ".format(args.server_uuid, args.start_trans, args.end_trans)
    cmd += "CHANGE MASTER TO MASTER_USER = '{0}', MASTER_PASSWORD = '{1}', ".format(args.repl_user, args.repl_password)
    cmd += "MASTER_HOST = '{0}', MASTER_PORT = {1}, ".format(args.repl_host, args.repl_port)
    cmd += "MASTER_AUTO_POSITION = 1; start slave;"

    return cmd

def get_skip_cmd(server_uuid, trans):
    cmd  = "stop slave; "
    cmd += "set session gtid_next = '{0}:{1}'; ".format(server_uuid, trans)
    cmd += "begin; commit; "
    cmd += "set session gtid_next = 'AUTOMATIC'; "
    cmd += "start slave;"

    return cmd

def purge_gtid_trans(credential, args):
    mysql_cmd = get_purge_cmd(args)
    cmd = 'mysql {0} -e "{1}"'.format(credential, mysql_cmd)
    ret, res = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print res,
        return ret

    cmd = 'mysql {0} -e "show slave status\G;"'.format(credential)
    ret, res = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
    print res

    return ret

def skip_gtid_trans(credential, args):
    mysql_cmd = get_skip_cmd(args.server_uuid, args.trans_id)
    cmd = 'mysql {0} -e "{1}"'.format(credential, mysql_cmd)
    ret, res = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d) [%d, %d, %d]' % (cmd,
    			ret, args.start_trans, trans, args.end_trans)
        print res
    return ret

def parse_args():
    parser = argparse.ArgumentParser(prog = 'python {0}'.format(sys.argv[0]))

    parser.add_argument("--host", metavar = '<host>',
            default = 'localhost', help = 'slave mysql host, default localhost')
    parser.add_argument("--port", metavar = '<port>',
            default = 3306, help = 'slave mysql port, default 3306')
    parser.add_argument("--user", metavar = '<user>',
            required = True, help = 'slave mysql user')
    parser.add_argument("--password", metavar = '<password>',
            required = True, help = 'slave mysql user password')
    parser.add_argument("--server_uuid", metavar = '<uuid>',
            required = True, help = 'master mysql server uuid')

    subparsers = parser.add_subparsers(metavar = '<subcommand>')

    parser_skip = subparsers.add_parser('skip', help = 'skip an error transaction')
    parser_skip.add_argument("trans_id", metavar = '<trans id>',
            type = int, help = 'the transaction ID of master mysql server')
    parser_skip.set_defaults(func = skip_gtid_trans)

    parser_purge = subparsers.add_parser('purge', help = 'purge several transaction errors')
    parser_purge.add_argument("--repl_port", metavar = '<repl port>',
            default = 3306, help = 'master mysql port, default 3306')
    parser_purge.add_argument("--repl_user", metavar = '<repl user>',
            required = True, help = 'master mysql repl user')
    parser_purge.add_argument("--repl_password", metavar = '<repl password>',
            required = True, help = 'master mysql repl user password')
    parser_purge.add_argument("--repl_host", metavar = '<repl host>',
            required = True, help = 'master mysql host')
    parser_purge.add_argument("start_trans", metavar = '<start>',
            type = int, help = 'the first transaction ID of master mysql server')
    parser_purge.add_argument("end_trans", metavar = '<end>',
            type = int, help = 'the last transaction ID of master mysql server')
    parser_purge.set_defaults(func = purge_gtid_trans)

    return parser.parse_args()

def main(argv):
    args = parse_args()

    credential = '-u{0} -p{1} -h{2} -P{3}'.format(args.user, args.password, args.host, args.port)

    return args.func(credential, args)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
