#! /bin/bash

if [ $# -ne 1 ]; then
	printf "Usage:\n\tbash $0 <IPsFile>\n"
	printf "Example:\n\tbash $0 hostIPs.txt\n"
	exit 1
fi

for host in $(cat $1)
do
	#python setnopwd.py $host
	scp *.deb $host:~/
	ssh $host "dpkg -i libaio1_0.3.109-4_amd64.deb"
	ssh $host "dpkg -i libibverbs1_1.1.7-1ubuntu1.1_amd64.deb"
	ssh $host "dpkg -i librdmacm1_1.0.16-1_amd64.deb"
	ssh $host "dpkg -i fio_2.1.3-1_amd64.deb"
done
