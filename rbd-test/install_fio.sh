#! /bin/bash

if [ $# -eq 0 ]; then
    dpkg -i libaio1_0.3.109-4_amd64.deb
    dpkg -i libibverbs1_1.1.7-1ubuntu1.1_amd64.deb
    dpkg -i librdmacm1_1.0.16-1_amd64.deb
    dpkg -i fio_2.1.3-1_amd64.deb
elif [ $# -eq 1 ]; then
    if [ -f $1 ]; then
        for host in $(cat $1)
        do
            #python setnopwd.py $host
            scp *.deb $host:~/
            ssh $host "dpkg -i libaio1_0.3.109-4_amd64.deb"
            ssh $host "dpkg -i libibverbs1_1.1.7-1ubuntu1.1_amd64.deb"
            ssh $host "dpkg -i librdmacm1_1.0.16-1_amd64.deb"
            ssh $host "dpkg -i fio_2.1.3-1_amd64.deb"
        done
    else
        scp *.deb $1:~/
        ssh $1 "dpkg -i libaio1_0.3.109-4_amd64.deb"
        ssh $1 "dpkg -i libibverbs1_1.1.7-1ubuntu1.1_amd64.deb"
        ssh $1 "dpkg -i librdmacm1_1.0.16-1_amd64.deb"
        ssh $1 "dpkg -i fio_2.1.3-1_amd64.deb"
    fi
else
    printf "Usage:\n\tbash $0 [<IPsFile>|<IP>]\n"
    printf "Example:\n\tbash $0 hostIPs.txt\n"
    printf "\tbash $0 1.1.1.1\n"
    printf "\tbash $0\n"
    exit 1
fi
