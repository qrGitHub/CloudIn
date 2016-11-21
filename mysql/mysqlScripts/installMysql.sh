#!/bin/bash

MYSQL_ROOT_PASSWD=111111
MYSQL_VERSION=5.6

function installMySQL() {
    # Usage: installMySQL <mysql version> <root password>
    echo mysql-server-"$1" mysql-server/root_password password "$2" | sudo debconf-set-selections
    echo mysql-server-"$1" mysql-server/root_password_again password "$2" | sudo debconf-set-selections
    bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y mysql-server-$1"
}

installMySQL $MYSQL_VERSION $MYSQL_ROOT_PASSWD
