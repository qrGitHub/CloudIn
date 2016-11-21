#!/bin/bash

if [ "$#" -eq 1 ]; then
    ver=$1
else
    ver=5.6
fi

apt-get remove -y mysql-server-$ver mysql-server-core-$ver mysql-client-$ver mysql-client-core-$ver mysql-common mysql-common-$ver
dpkg --purge mysql-server-$ver mysql-common mysql-common-$ver libmysqlclient18

#debconf-get-selections | grep mysql
#echo PURGE | debconf-communicate mysql-server-5.6
#echo PURGE | debconf-communicate debconf
