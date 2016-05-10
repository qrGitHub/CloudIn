#!/bin/sh
password="SbTj^_^!dr521"
MASTER_STATUS=$(mysql -h192.168.210.76 -P3340 -upay_root -p"$password" -e"show master status \G")

time=`date +"%Y-%m-%d %H:%M:%S"`
echo "==================="
echo "$time"
echo "STATUS:  $MASTER_STATUS"

if [ "$MASTER_STATUS" == "" ];then
echo "mysql abnormal"
AlarmClient "S_game_pay" "lv3" "payMysqlMasterAbnormal" "pay mysql master(192.168.210.76) abnormal" 1
fi
