#!/bin/bash

waitRebootFinish() {
    local start_time=$(date +%s)
    let "end_time = start_time + $2"

    while [ 1 ]
    do
        ping -c 1 $1 > /dev/null
        if [ $? -eq 0 ]; then
            return 0
        fi

        now_time=$(date +%s)
        if [ $now_time -ge $end_time ]; then
            return 1
        fi
    done
}

copyAndInstallCeph() {
    scp -r debpkg $1:/root/
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "copy debpkg to $1 failed"
        return $ret
    fi

    ssh $1 "cd debpkg && bash installDependPkgs.sh"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "run installDependPkgs.sh on $1 failed"
        return $ret
    fi

    ssh $1 "cd debpkg && bash prepare.sh"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "run prepare.sh on $1 failed"
        return $ret
    fi

    ssh $1 "cd debpkg && bash install.sh"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "install ceph packages on $1 failed"
        return $ret
    fi
}

cephConf=deploy.conf
hostsList=$(grep hosts $cephConf | awk -F'=' '{print $2}' | awk -F',' '{for(i = 1; i <= NF; i++) print $i}' | sort | uniq)
for host in $hostsList
do
    python setPasswordless.py --hostname $host --username root --password '1qaz2wsx$RFV' --port 22
    if [ $? -ne 0 ]; then
        echo "set passwordless for $host failed"
        exit 1
    fi

    copyAndInstallCeph $host
    if [ $? -ne 0 ]; then
        echo "copy and install ceph packages on $host failed"
        exit 1
    fi

    ssh $host "sed -i 's/ubuntu/'$host'/' /etc/hosts"
    ssh $host "sed -i 's/ubuntu/'$host'/' /etc/hostname"
    ssh $host "reboot"
    waitRebootFinish $host 60
done
