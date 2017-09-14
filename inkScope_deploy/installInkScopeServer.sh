#!/bin/bash

doCommand() {
	echo "^_^: $*"
	eval $*
	[ $? -eq 0 ] || exit 1
}

doCommand sudo apt-get install -y python-pip apache2 libapache2-mod-wsgi mongodb python-dev
doCommand sudo dpkg -i inkscope-common_1.3.0-0_all.deb inkscope-admviz_1.3.0-0_all.deb

doCommand sudo dpkg -i inkscope-cephrestapi_1.3.0-0_all.deb inkscope-cephprobe_1.3.0-0_all.deb
ceph auth get-or-create client.restapi mds 'allow' osd 'allow *' mon 'allow *' > /etc/ceph/ceph.client.restapi.keyring
conffile=/etc/ceph/ceph.conf
echo "[client.restapi]" >> $conffile
echo "    log_file = /dev/null" >> $conffile
echo "    keyring = /etc/ceph/ceph.client.restapi.keyring" >> $conffile

conffile=/opt/inkscope/etc/inkscope.conf
inkScopeServer=223.202.85.116
mongodbServer=10.1.0.16
sed -i 's/"ceph_rest_api":.*$/"ceph_rest_api": "'$inkScopeServer':8080",/' $conffile
sed -i 's/"ceph_rest_api_subfolder":.*$/"ceph_rest_api_subfolder": "ceph_rest_api",/' $conffile
sed -i 's/"mongodb_host".*$/"mongodb_host" : "'$mongodbServer'",/' $conffile
doCommand chmod a+r $conffile

conffile=/etc/apache2/sites-available/inkScope.conf
doCommand cp inkScope.conf $conffile

conffile=/etc/apache2/ports.conf 
sed -i '/Listen 80/a\Listen 8080' $conffile

doCommand pip install flask-login simple-json

doCommand sudo a2enmod rewrite
doCommand sudo a2ensite inkScope
doCommand sudo service apache2 restart

doCommand pip install psutil==2.1.3
doCommand /etc/init.d/cephprobe start

conffile=/etc/mongodb.conf
sed -i 's/bind_ip =.*$/bind_ip = 0.0.0.0/' $conffile
sed -i 's/#port = 27017/port = 27017/' $conffile
doCommand service mongodb restart
