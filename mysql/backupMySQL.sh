mysql -s -s -e "show databases;" | grep -vE "information_schema|mysql|performance_schema" | xargs mysqldump --single-transaction -R --databases | gzip -9 > mysql_$(date +%y%m%d).sql.gz
