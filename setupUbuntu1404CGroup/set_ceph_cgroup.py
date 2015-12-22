#!/usr/bin/env python
# coding=utf-8

import sys
import getopt
import os
import re
import platform
#import paramiko

def do_local_cmd(cmd):
    print "%s" % cmd
    #out = os.system(cmd)
    #if out:
    #    print "Error code: %d" % out
    #    sys.exit(1)
    return

def do_local_cmd_with_return(cmd):
    output_list_ori = os.popen(cmd).readlines()
    output_list = []
    for item in output_list_ori:
        output_list.append(item.strip('\n'))
    return output_list

def connect_remote_host(host):
    s = paramiko.SSHClient()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname = host,port=22,username="root",password="")
    return s

def disconnect_remote_host(s):
    s.close()
    return

def do_remote_cmd(s, cmd):
    print "Do command: %s" % cmd
    (stdin, stdout, stderr) = s.exec_command(cmd)
    #print stdout.read()
    result = filter(None, re.split('\n', stdout.read()))
    return result

def install_cgroup(sc):
    do_remote_cmd(sc, "which cgcreate > /dev/null || apt-get install -y cgroup-bin")
    return

def set_osds_cg_cpuset_cpus(osds):
    max_cpu_num = do_local_cmd_with_return("cat /sys/fs/cgroup/cpuset/cpuset.cpus | awk -F '[-]' '{print $2}'")
    if conf_debug: max_cpu_num = ["31"]
    cpus = int(max_cpu_num[0])
    for osd_id in osds:
        do_local_cmd("echo " + str(cpus) + " > /sys/fs/cgroup/cpuset/ceph_osd/osd" + osd_id + "/cpuset.cpus")
        cpus -= 1
    return

def set_osds_cg_cpuset_mems(osds):
    mems = do_local_cmd_with_return("cat /sys/fs/cgroup/cpuset/cpuset.mems")
    if conf_debug: mems = ["0"]
    for osd_id in osds:
        do_local_cmd("echo " + mems[0] + " > /sys/fs/cgroup/cpuset/ceph_osd/osd" + osd_id + "/cpuset.mems")
    return

def set_osds_cg_memory(osds):
    if conf_cgroup_mem != True: return
    for osd_id in osds:
        for (k, v) in osd_mems_conf.items():
            do_local_cmd("echo " + v + " > /sys/fs/cgroup/memory/ceph_osd/osd" + osd_id + "/" + k)
    return

def modify_ceph_osd_conf():
    ## modify ceph-osd.conf
    do_local_cmd("sed '/cpuacct,cpuset,memory/d' /etc/init/ceph-osd.conf > /tmp/ceph-osd.conf; mv /tmp/ceph-osd.conf /etc/init/ceph-osd.conf")
    do_local_cmd("sed -i 's/^exec /#exec /g' /etc/init/ceph-osd.conf")
    do_local_cmd("sed -i '/exec /aexec cgexec -g cpu,cpuacct,cpuset,memory:ceph_osd/osd\"$id\" /usr/bin/ceph-osd --cluster=\"${cluster:-ceph}\" -i \"$id\" -f' /etc/init/ceph-osd.conf")

    return

def do_osd_cgcreate(host):
    ## Initialize connection
    #sc = connect_remote_host(host)

    ## Install and create cgroup
    #install_cgroup(sc)
    osds = do_local_cmd_with_return("ls /var/lib/ceph/osd/ | sed 's/ceph-//'")
    if not osds:
        print "No osd  on host %s" % host
        return

    if conf_debug: osds = ["0", "1", "2", "3"]
    print "osds: %s" % osds
    for osd_id in osds:
        do_local_cmd("cgcreate -g cpu,cpuacct,cpuset,memory:ceph_osd/osd" + osd_id)

    ## Configure osds cgroup
    set_osds_cg_cpuset_cpus(osds)
    set_osds_cg_cpuset_mems(osds)
    set_osds_cg_memory(osds)
    modify_ceph_osd_conf()

    # Restart ceph-osd daemon
    do_local_cmd("restart ceph-osd-all")

    ## Disconnet connection
    #disconnect_remote_host(sc)
    return

def do_osd_cgdelete(host):
    ## Initialize connection
    sc = connect_remote_host(host)

    osds = do_remote_cmd(sc, "ls /var/lib/ceph/osd/ | sed 's/ceph-//'")
    if not osds:
        print "No osd  on host %s" % host
        return

    if conf_debug: osds = ["0", "1", "2", "3"]
    print "osds: %s" % osds
    for osd_id in osds:
        do_remote_cmd(sc, "cgdelete -g cpu,cpuacct,cpuset,memory:ceph_osd/osd" + osd_id)

    ## Disconnet connection
    disconnect_remote_host(sc)
    return

def set_mon_cg_cpuset_cpus(mons):
    for mon_id in mons:
        do_local_cmd("echo 0 > /sys/fs/cgroup/cpuset/ceph_mon/mon" + mon_id + "/cpuset.cpus")
    return

def set_mon_cg_cpuset_mems(mons):
    mems = do_local_cmd_with_return("cat /sys/fs/cgroup/cpuset/cpuset.mems")
    if conf_debug: mems = ["0"]
    print "mems: %s" % mems[0]

    for mon_id in mons:
        do_local_cmd("echo " + mems[0] + " > /sys/fs/cgroup/cpuset/ceph_mon/mon" + mon_id + "/cpuset.mems")
    return

def set_mon_cg_memory(mons):
    if conf_cgroup_mem != True: return
    for (k, v) in mon_mems_conf.items():
        do_local_cmd("echo " + v + " > /sys/fs/cgroup/memory/ceph_mon/mon" + mons[0] + "/" + k)
    return

def modify_ceph_mon_conf():
    ## modify ceph-mon.conf
    do_local_cmd("sed '/exec cgexec/d' /etc/init/ceph-mon.conf > /tmp/ceph-mon.conf; mv /tmp/ceph-mon.conf /etc/init/ceph-mon.conf")
    do_local_cmd("sed -i 's/^exec /#exec /g' /etc/init/ceph-mon.conf")
    do_local_cmd("sed -i '/exec /aexec cgexec -g cpu,cpuacct,cpuset,memory:ceph_mon/mon\"$id\" /usr/bin/ceph-mon --cluster=\"${cluster:-ceph}\" -i \"$id\" -f' /etc/init/ceph-mon.conf")

    return

def do_mon_cgcreate(host):
    ## Initialize connection
    #sc = connect_remote_host(host)

    ## Install and create cgroup
    #install_cgroup(sc)
    mons = do_local_cmd_with_return("ls /var/lib/ceph/mon/ | sed 's/ceph-//'")
    if not mons:
        print "No monitor on host %s" % host
        return

    if conf_debug: mons = ["0"]
    print "mons: %s" % mons
    for mon_id in mons:
        do_local_cmd("cgcreate -g cpu,cpuacct,cpuset,memory:ceph_mon/mon" + mon_id)

    ## Configure osds cgroup
    set_mon_cg_cpuset_cpus(mons)
    set_mon_cg_cpuset_mems(mons)
    set_mon_cg_memory(mons)
    modify_ceph_mon_conf()

    # Restart ceph-mon daemon
    do_local_cmd("restart ceph-mon-all")

    ## Disconnet connection
    #disconnect_remote_host(sc)
    return

def do_mon_cgdelete(host):
    ## Initialize connection
    sc = connect_remote_host(host)

    mons = do_remote_cmd(sc, "ls /var/lib/ceph/mon/ | sed 's/ceph-//'")
    if not mons:
        print "No monitor on host %s" % host
        return

    if conf_debug: mon_id = "0"
    print "mons: %s" % mons
    for mon_id in mons:
        do_remote_cmd(sc, "cgdelete -g cpu,cpuacct,cpuset,memory:ceph_mon/mon" + mon_id)

    ## Disconnet connection
    disconnect_remote_host(sc)
    return

def do_hosts_cgcreate(component, hosts):
    for host in hosts:
        if component == "monitor":
            do_mon_cgcreate(host)
        elif component == "osd":
            do_osd_cgcreate(host)
        else:
            print "Error ceph component: %s" % component

    return

def do_hosts_cgdelete(component, hosts):
    for host in hosts:
        if component == "monitor":
            do_mon_cgdelete(host)
        elif component == "osd":
            do_osd_cgdelete(host)
        else:
            print "Error ceph component: %s" % component
    return

def do_set_ceph_cgroup(hosts, cgdelete):
    mhosts = hosts["mons"]
    ohosts = hosts["osds"]

    if cgdelete:
        ## delete monitors/osds cgroup
        do_hosts_cgdelete("monitor", mhosts)
        do_hosts_cgdelete("osd", ohosts)
    else:
        ## create monitors/osds cgroup
        do_hosts_cgcreate("monitor", mhosts)
        do_hosts_cgcreate("osd", ohosts)
    return

def set_local_cgroup(cgdelete):
    hostname = do_local_cmd_with_return("hostname")
    result = do_local_cmd_with_return("ceph -s | grep " + hostname[0])
    #print "hostname:%s %s" %(hostname, result)
    if result:
        do_mon = True
    else:
        do_mon = False

    if cgdelete:
        if do_mon:
            do_mon_cgdelete("localhost")
        do_osd_cgdelete("localhost")
    else:
        if do_mon:
            do_mon_cgcreate("localhost")
        do_osd_cgcreate("localhost")
    return

def usage(name):
    print "Usage:"
    print "    python %s < -l | -h | -v >" % name
    print "    -l                just set local cgroup"
    print "    -h, --help        print help message"
    print "    -v, --version     print script version"

def version():
    print "version 1.0"

def main(argv):
    global conf_debug, ceph_hosts
    cgdelete = only_set_local = False

    try:
        opts, args = getopt.getopt(argv[1:], 'hvlm', ['help', 'version', 'debug', 'local', 'delete'])
    except getopt.GetoptError, err:
        print str(err)
        usage(argv[0])
        sys.exit(2)

    for op, value in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            sys.exit(1)
        elif op in ('-v', '--version'):
            version()
            sys.exit(0)
        elif op in ('-l'):
            only_set_local = True
        elif op in ('--debug'):
            conf_debug = True
        elif op in ('--delete'):
            cgdelete = True
        else:
            usage(argv[0])
            sys.exit(1)

    # Main entrance
    if only_set_local:
        set_local_cgroup(cgdelete)
        sys.exit(0)

    #do_set_ceph_cgroup(ceph_hosts, cgdelete)

# Configuration of this script
conf_debug = False
conf_cgroup_mem = True

osd_mems_conf = {"memory.limit_in_bytes" : "5G",
                 "memory.soft_limit_in_bytes" : "2G",
                 "memory.swappiness" : "0"}
mon_mems_conf = {"memory.limit_in_bytes" : "5G",
                 "memory.soft_limit_in_bytes" : "3G",
                 "memory.swappiness" : "0"}
ceph_hosts = {"mons": {"BJ-BGP01-002-03"},
              "osds": {"BJ-BGP01-002-03"}}
#ceph_hosts = {"mons": {"BJ-BGP01-002-02", "BJ-BGP01-002-03", "BJ-BGP01-003-02"},
#              "osds": {"BJ-BGP01-002-01", "BJ-BGP01-002-02", "BJ-BGP01-002-03", "BJ-BGP01-002-04", "BJ-BGP01-002-05", "BJ-BGP01-002-06", "BJ-BGP01-002-07", "BJ-BGP01-002-08", "BJ-BGP01-003-01", "BJ-BGP01-003-02", "BJ-BGP01-003-04", "BJ-BGP01-003-05", "BJ-BGP01-003-07", "BJ-BGP01-003-08"}}

if __name__ == '__main__':
    main(sys.argv)

