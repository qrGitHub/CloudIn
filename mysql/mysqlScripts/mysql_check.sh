cd /home/web/.script/mysql

#mysql restart at 6am
#if [[ `date "+%H%M"` -le  0600 ]] || [[ `date "+%H%M"` -ge 0610 ]] && [[ `date "+%H%M"` -le 0330 ]] || [[ `date "+%H%M"` -ge 0350 ]] ; then
#check mysql is alive or not
d=`date "+%Y%m%d"`
log_file="/home/web/logs/AdSystem/mysql/mysql_alarm_$d.log"
status=`/home/web/mysql-5.5.21-linux2.6-x86_64/bin/mysqladmin ping --socket=/tmp/mysqlad.sock |grep -c "is alive"`

if [ $status -eq 0 ] ; then
        echo `date "+%Y-%m-%d_%H:%M:%S"` "failed" >> $log_file
        AlarmClient S_game_adv lv3 "167AdSystemDBNotAlive" "mysql is not alive" 1
        exit 0
fi
echo `date "+%Y-%m-%d_%H:%M:%S"` "success" >> $log_file

#record processes
date >> /home/web/logs/AdSystem/mysql/mysql_process_$d.log
mysql -uroot --socket=/tmp/mysqlad.sock -e "show full processlist" >> /home/web/logs/AdSystem/mysql/mysql_process_$d.log


#check sync status
log_file="/home/web/logs/AdSystem/mysql/mysql_sync_alarm_$d.log"
data=`mysql -uroot --socket=/tmp/mysqlad.sock -e "show slave status\G"`
result=`echo "$data"|awk -fmysql_sync_alarm.awk`
echo `date "+%Y-%m-%d_%H:%M:%S"` $result >> $log_file
if [ "$result" != "success" ] ; then
	AlarmClient S_game_adv lv3 "167AdSystemDB" "mysql is not sync" 1
        echo "$data" >> $log_file
fi
#fi
