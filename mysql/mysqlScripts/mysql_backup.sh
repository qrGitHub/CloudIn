#!/bin/sh
cd /data/backup/mysql/pay/
#must be root user

time=`date +"%Y-%m-%d %H:%M:%S"`
echo "============"
echo "$time"

my_ip=`/sbin/ifconfig em1 | grep 'inet addr' | awk  '{print substr($2, index($2, ":")+1)}'`
msg="mysql_backup_failed..."

date=`date "+%u"`
echo "Must be root user!"
echo "Begin mysqldump..."
mysqldump -uroot --socket=/tmp/mysql5.1.21.sock -P3340  --default-character-set=utf8 PAY > PAY.sql.$date
mysqldump -uroot --socket=/tmp/mysql5.1.21.sock -P3340  --default-character-set=utf8 MOBILE_PAY > MOBILE_PAY.sql.$date
mysqldump -uroot --socket=/tmp/mysql5.1.21.sock -P3340  --default-character-set=utf8 VIP_USER > VIP_USER.sql.$date
mysqldump -uroot --socket=/tmp/mysql5.1.21.sock -P3340  --default-character-set=utf8 DJ_USER > DJ_USER.sql.$date
mysqldump -uroot --socket=/tmp/mysql5.1.21.sock -P3340  --default-character-set=utf8 ZHONGCHOU > ZHONGCHOU.sql.$date
mysqldump -uroot --socket=/tmp/mysql5.1.21.sock -P3340  --default-character-set=utf8 SERVICE_PAYINFO > SERVICE_PAYINFO.sql.$date
if [ $? -ne 0 ] ; then
        echo "mysql_cold_backup_error" 
	AlarmClient "S_game_pay" "lv2" "payMysqlColdBackupErr" "$msg ${my_ip}" 1
fi

#backup to 60.28.205.52
scp PAY.sql.$date web@192.168.201.30:/data1/backup/mysql/pay
scp MOBILE_PAY.sql.$date web@192.168.201.30:/data1/backup/mysql/pay
scp VIP_USER.sql.$date web@192.168.201.30:/data1/backup/mysql/pay
scp DJ_USER.sql.$date web@192.168.201.30:/data1/backup/mysql/pay
scp ZHONGCHOU.sql.$date web@192.168.201.30:/data1/backup/mysql/pay
scp SERVICE_PAYINFO.sql.$date web@192.168.201.30:/data1/backup/mysql/pay

if [ $? -ne 0 ] ; then
        echo "mysql_cold_backup_error while scp to 201.30" 
	AlarmClient "S_game_pay" "lv1" "payMysqlColdScpErr" "$msg while scp to 201.30, ${my_ip}" 1
fi

end_time=`date +"%Y-%m-%d %H:%M:%S"`
echo "$end_time"
echo "backup Finish"
