#!/bin/bash

hostList=($(cat hostList.txt))

pull_confs() {
    for host in ${hostList[@]}
    do
        scp root@${host}:/etc/ceph/ceph.conf ${host}.conf
    done
}

push_file() {
    if [ $# -ne 2 ]; then
        return 1
    fi

    for host in ${hostList[@]}
    do
        scp "$1" root@${host}:$2
    done
}

compare_confs() {
    for i in ${hostList[@]}
    do
        local f_i=${i}.conf
        for j in ${hostList[@]}
        do
            local f_j=${j}.conf
            if [ "$f_i" == "$f_j" ]; then
                continue
            fi

            diff -u $f_i $f_j > /dev/null
            if [ $? -ne 0 ]; then
                echo "$f_i $f_j differ"
            fi
        done
    done
}

pull_confs
compare_confs

#push_file ceph.conf /etc/ceph/
#push_file radosgw_10.2.5-cloudin.0.2.1_amd64.deb /tmp/
#push_file 5_setup_rgw.sh /tmp/

#push_file ceph/check_ceph.sh /opt/openstack/zabbix/script/ceph/ 
#push_file ceph/monitor_ceph.sh /opt/openstack/zabbix/script/ceph/ 
#push_file ceph/monitor_mem_free.py /opt/openstack/zabbix/script/ceph/ 
#push_file ceph/radosgw_avail.py /opt/openstack/zabbix/script/ceph/ 
