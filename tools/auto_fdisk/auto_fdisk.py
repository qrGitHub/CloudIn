#!/usr/bin/env python
#-*- coding:utf-8 -*-

from configure import cfg
import sys, re, os
import subprocess
import argparse

def doCommand(cmd):
    process = subprocess.Popen('set -o pipefail; ' + cmd, executable = '/bin/bash',
                shell = True, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        return process.returncode, process.stderr.read()
    else:
        return 0, process.stdout.read()

def parse_args():
    parser = argparse.ArgumentParser(prog = 'python {0}'.format(sys.argv[0]))
    parser.add_argument("-n", "--dry-run", action = "store_true",
                        help = 'perform a trial run with no changes made')

    return parser.parse_args()

def get_matched(string, pattern):
    matchObj = pattern.match(string)
    return matchObj.group(1) if matchObj else None

def split_device(dev):
    no = get_matched(dev, re.compile(r'^[^\d]*(\d+)$'))
    name = get_matched(dev, re.compile(r'^([^\d]+)'))

    return name, int(no) if no else None

def get_partition(dev_str, default_size):
    if dev_str.find(':') != -1:
        size = dev_str.split(':')[1].strip()
        dev = dev_str.split(':')[0].strip()
    else:
        size = default_size
        dev = dev_str.strip()

    if '' == dev:
        return None, None, None

    if dev.find('/') != 0:
        dev = '/dev/{0}'.format(dev)

    dev_name, dev_no = split_device(dev)
    return dev_name, dev_no, size

def get_create_partition_cmd(dev, partition):
    if 'rest' == partition[1]:
        cmd = r'echo -e "n\n\n{1}\n\n\nw\n" | sudo fdisk {0}'.format(dev, partition[0])
    else:
        cmd = r'echo -e "n\n\n{1}\n\n+{2}\nw\n" | sudo fdisk {0}'. \
                        format(dev, partition[0], partition[1])
    return cmd + ' && sudo partprobe {0}'.format(dev)

def get_partition_count(dev):
    cmd = 'sudo fdisk -l {0} | grep ^{0} | wc -l'.format(dev)
    ret, res = doCommand(cmd)
    if ret != 0:
        sys.stderr.write('run command `%s` failed(%d)\n' % (cmd, ret))
        sys.stderr.write(res)
        return ret, None

    return 0, int(res)

def get_delete_partition_cmd(dev, partition):
    ret, count = get_partition_count(dev)
    if count > 1:
        cmd = r'echo -e "d\n{1}\nw\n" | sudo fdisk {0}'.format(dev, partition[0])
    else:
        cmd = r'echo -e "d\nw\n" | sudo fdisk {0}'.format(dev)

    return cmd + ' && sudo partprobe {0}'.format(dev)

def do_fdisk_on_host(conf, host, action, dry_run):
    ret, res = doCommand('hostname')
    if ret != 0:
        sys.stderr.write('run command `hostname` failed(%d)\n' % ret)
        sys.stderr.write(res)
        return ret
    local_host = res.strip()
    prefix = 'ssh {0} '.format(host) if host != local_host else ''

    for dev in conf[host]:
        for partition in conf[host][dev]:
            if 'create' == action:
                cmd = get_create_partition_cmd(dev, partition)
            elif 'delete' == action:
                if not os.path.exists('{0}{1}'.format(dev, partition[0])):
                    continue

                cmd = get_delete_partition_cmd(dev, partition)
            else:
                sys.stderr.write("action[%s] for fdisk isn't supported]\n" % action)
                return 1

            if prefix != '':
                cmd = "{0}'{1}'".format(prefix, cmd)

            if not dry_run:
                ret, res = doCommand(cmd)
                if ret != 0:
                    sys.stderr.write('run command `%s` failed(%d)\n' % (cmd, ret))
                    sys.stderr.write(res)
                    return ret
            else:
                sys.stdout.write('%s\n' % cmd)

    return 0

def sorted_insert(section_conf, dev_name, dev_no, dev_size):
    if dev_name not in section_conf:
        section_conf[dev_name] = [(dev_no, dev_size)]
        return

    for i, val in enumerate(section_conf[dev_name]):
        if dev_no <= val[0]:
            section_conf[dev_name].insert(i, (dev_no, dev_size))
            return
    section_conf[dev_name].insert(i + 1, (dev_no, dev_size))

def parse_section(cfg, section, global_devs, global_size, conf):
    default_size = cfg.get(section, 'size') if cfg.has_option(section, 'size') else global_size
    devs = cfg.get(section, 'devs') if cfg.has_option(section, 'devs') else global_devs
    if not devs:
        sys.stderr.write("host %s has no device list\n" % section)
        return 1

    conf[section] = {}
    for item in devs.split(','):
        dev_name, dev_no, dev_size = get_partition(item, default_size)
        if not dev_name:
            continue

        if None == dev_no:
            sys.stderr.write("partition No. is require for [%s, %s]\n" % (section, item))
            return 1

        if None == dev_size:
            sys.stderr.write("size is require for [%s, %s]\n" % (section, item))
            return 1

        sorted_insert(conf[section], dev_name, dev_no, dev_size)

    return 0

def parse_conf(cfg):
    global_size = cfg.get('global', 'size') if cfg.has_option('global', 'size') else None
    global_devs = cfg.get('global', 'devs') if cfg.has_option('global', 'devs') else None
    conf = {}

    for section in cfg.sections():
        if 'global' == section:
            continue

        ret = parse_section(cfg, section, global_devs, global_size, conf)
        if ret != 0:
            sys.stderr.write("parse section %s failed\n" % section)
            return ret, conf

    return 0, conf

def do_fdisk(conf, action, dry_run = False):
    for host in conf:
        ret = do_fdisk_on_host(conf, host, action, dry_run)
        if ret != 0:
            sys.stderr.write("do fdisk %s on host %s failed\n" % (action, host))
            return ret

    return 0

def main(argv):
    args = parse_args()

    ret, conf = parse_conf(cfg)
    if ret != 0:
        sys.stderr.write("parse CONF failed\n")
        return 1

    ret = do_fdisk(conf, 'delete', args.dry_run)
    if ret != 0:
        sys.stderr.write("do_fdisk delete failed\n")
        return ret

    ret = do_fdisk(conf, 'create', args.dry_run)
    if ret != 0:
        sys.stderr.write("do_fdisk create failed\n")
        return ret

    return ret

if '__main__' == __name__:
    sys.exit(main(sys.argv))
