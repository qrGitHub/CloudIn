#!/bin/bash

mysql_host="192.168.226.167"
mysql_user="root"
mysql_passwd=""
mysql_socket="/tmp/mysql3.sock"
mysql_port="3308"
nodeldb=("Database information_schema mysql test")

back_dir="/data/backup/mysql/ringback"

if [ ! -d $back_dir ]; then
	mkdir -p $back_dir
fi

db_arr=$(echo "SHOW DATABASES;" | mysql -u$mysql_user --socket=$mysql_socket --port=$mysql_port)
echo ${db_arr[@]}
date=$(date +%w)

cd $back_dir
date_time=`date "+%Y%m%d"`
echo "start back databases $date_time"
flag="true"
for dbname in ${db_arr}
do

	for nodeldbname in ${nodeldb}
	do
		if [ "$dbname" == "$nodeldbname" ]; then
			flag="flase"
			break
		fi
	done
	
	if [ "$flag" != "flase" ]; then
		sqlfile=$dbname-$date".sql"
		echo $dbname
		mysqldump -u$mysql_user --socket=$mysql_socket --port=$mysql_port $dbname > $sqlfile
		scp $sqlfile  web@192.168.201.30:/data1/backup/mysql/ringback
	else
		flag="true"
	fi


done

