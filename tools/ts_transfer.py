#!/usr/bin/env python
#-*- coding:utf-8 -*-

import subprocess
import argparse
import sys, re

def doCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable='/bin/bash', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def parse_args():
    parser = argparse.ArgumentParser(prog = 'python {0}'.format(sys.argv[0]))
    parser.add_argument("file_name", metavar = '<file name>', help = 'the log file')

    return parser.parse_args()

def get_startup_ts():
    cmd = 'date +%s'
    ret, now = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print now,
        return ret, 0

    cmd = "cat /proc/uptime | cut -f 1 -d' '"
    ret, duration = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print duration,
        return ret, 0

    return 0, float(now) - float(duration)

def ts_transfer(startup_ts, old_ts):
    cmd = 'date -d "1970-01-01 UTC {0} seconds"'.format(startup_ts + float(old_ts))
    ret, res = doCommand(cmd)
    if ret != 0:
        print 'run command `%s` failed(%d)' % (cmd, ret)
        print res,
        return ret

    return res.strip()

def process_one_line(line, pattern, startup_ts):
    matchObj = pattern.match(line)
    if matchObj:
        res = matchObj.group(1)
    else:
        print line,
        return 1

    ts = ts_transfer(startup_ts, res)
    line = line.replace(res, ts)
    print line,
    return 0

def main(argv):
    args = parse_args()

    ret, startup_ts = get_startup_ts()
    if ret != 0:
        print 'get startup timestamp failed'
        return ret

    pattern = re.compile(r'^\[(\d+\.\d+)\]')

    with open(args.file_name) as f:
        try:
            for line in f:
                process_one_line(line, pattern, startup_ts)
        except IOError:
            pass

if __name__ == '__main__':
    sys.exit(main(sys.argv))
