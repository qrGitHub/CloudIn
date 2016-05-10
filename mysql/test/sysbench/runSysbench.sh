#!/bin/bash

host=localhost
port=3306
user=root
passwd=111111

db_name=sbtest

#print a log and then exit
function EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

#create database
mysql -u$user -p$passwd -e "drop database if exists $db_name;"
mysql -u$user -p$passwd -h $host -P $port -e "create database $db_name;"
[ $? -eq 0 ] || EXIT "Create database FAILED!"

# prepare data
time sysbench --oltp-table-size=5000000 --test=oltp --mysql-table-engine=innodb --mysql-host=$host --mysql-port=$port --mysql-user=$user --mysql-password=$passwd --mysql-db=$db_name prepare
[ $? -eq 0 ] || EXIT "Prepare data FAILED!"

# start benchmark
time sysbench --max-time=600 --max-requests=0 --num-threads=16 --oltp-table-size=5000000 --test=oltp --mysql-table-engine=innodb --mysql-host=$host --mysql-port=$port --mysql-user=$user --mysql-password=$passwd --mysql-db=$db_name run
[ $? -eq 0 ] || EXIT "Start benchmark FAILED!"

# cleanup environment
sysbench --num-threads=16 --oltp-table-size=5000000 --test=oltp --mysql-table-engine=innodb --mysql-host=$host --mysql-port=$port --mysql-user=$user --mysql-password=$passwd --mysql-db=$db_name cleanup
[ $? -eq 0 ] || EXIT "Cleanup FAILED!"

# delete database
mysql -u$user -p$passwd -h $host -P $port -e "drop database $db_name;"
[ $? -eq 0 ] || EXIT "Delete database FAILED!"
