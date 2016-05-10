#!/bin/bash

mysqlHost=localhost
mysqlPort=3306

mysqlPassword=111111
mysqlUser=root

ps aux | grep mysqld | grep -v grep > /dev/null 2>&1
if [ $? -ne 0 ]; then
    printf "MySQL daemon[mysqld] doesn't exist\n"
    exit 1
fi

netstat -nap | grep $mysqlPort > /dev/null 2>&1
if [ $? -ne 0 ]; then
    printf "MySQL port[%d] doesn't work\n", $mysqlPort
    exit 1
fi
 
mysql -u$mysqlUser -p$mysqlPassword -h $mysqlHost -e "show status;"  > /dev/null 2>&1
if [ $? -ne 0 ]; then
    printf "Run command 'show status' failed\n"
    exit 1
fi
