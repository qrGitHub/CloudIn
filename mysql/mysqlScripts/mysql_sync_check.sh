#!/bin/bash

function mysql_sync_monitor() {
	local mysql_socket=$1
	local mysql_port=$2
	local service=$3
	
	IO_STATUS=$(mysql -uroot --socket=$mysql_socket --port=$mysql_port -e"show slave status \G"| awk '{if($1~/Slave_IO_Running/)print $2}')
	SQL_STATUS=$(mysql -uroot --socket=$mysql_socket --port=$mysql_port -e"show slave status \G"| awk '{if($1~/Slave_SQL_Running/)print $2}')

	time=`date +"%Y-%m-%d %H:%M:%S"`
	echo "==================="
	echo "$time"
	echo "${service} IO_STATUS:  $IO_STATUS"
	echo "${service} SQL_STATUS: $SQL_STATUS"

	if [ "$IO_STATUS" != "Yes" -o "$SQL_STATUS" != "Yes" ];then
		echo "${service} mysql sync abnormal"
	AlarmClient "S_game_pay" "lv2" "${service}_MysqlSyncAbnormal" "60.28.226.167 ${service} mysql sync abnormal" 1
	fi
}

function mysql_second_behind_master_monitor() {
	local mysql_socket=$1
	local mysql_port=$2
	local service=$3
	second_behind=$(mysql -uroot --socket=$mysql_socket --port=$mysql_port -e"show slave status\G"|grep Seconds_Behind_Master|awk -F":" '{print $NF}')
	echo "Seconds_Behind_Master:"$second_behind
	if [ -z "$second_behind" -o "$second_behind" == "NULL" ];then
		echo "${service} mysql sync behind master $second_behind seconds"
		local _processlist=$(mysql -uroot --socket=$mysql_socket --port=$mysql_port -e"show full processlist;")
		echo "$_processlist"
		#AlarmClient "S_game_pay" "lv2" "${service}_MysqlSyncAbnormal" "60.28.226.167 ${service} mysql $second_behind behind master" 1
		exit 1
	fi
	if [  "$second_behind" -gt "1" ];then
		echo "${service} mysql sync behind master $second_behind seconds"
		local _processlist=$(mysql -uroot --socket=$mysql_socket --port=$mysql_port -e"show full processlist;")
		echo "$_processlist"
		#AlarmClient "S_game_pay" "lv2" "${service}_MysqlSyncAbnormal" "60.28.226.167 ${service} mysql $second_behind behind master" 1
	fi

}
function start_monitor() {
	mysql_sync_monitor "/tmp/mysql5.1.21.sock" "3340" "pay_from_port_3340"
	mysql_second_behind_master_monitor "/tmp/mysql5.1.21.sock" "3340" "pay_from_port_3340"
	mysql_sync_monitor "/tmp/mysql3.sock" "3308" "service_from_port_3308"
	mysql_second_behind_master_monitor "/tmp/mysql3.sock" "3308" "service_from_port_3308"
}

start_monitor

#IO_STATUS=$(mysql -uroot --socket=/tmp/mysql2.sock -e"show slave status \G"|awk '{if($1~/Slave_IO_Running/)print $2}')
#SQL_STATUS=$(mysql -uroot --socket=/tmp/mysql2.sock -e"show slave status \G"| awk '{if($1~/Slave_SQL_Running/)print $2}')

#time=`date +"%Y-%m-%d %H:%M:%S"`
#echo "==================="
#echo "$time"
#echo "IO_STATUS:  $IO_STATUS"
#echo "SQL_STATUS: $SQL_STATUS"

#if [ "$IO_STATUS" != "Yes" -o "$SQL_STATUS" != "Yes" ];then
#echo "game mysql sync abnormal"
#AlarmClient "S_game_game" "lv2" "gameMysqlSyncAbnormal" "60.28.226.167 game mysql sync abnormal" 1
#fi

