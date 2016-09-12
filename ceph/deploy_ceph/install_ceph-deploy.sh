#!/bin/bash

wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb http://download.ceph.com/debian-jewel $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
#sudo apt-get update
wget http://download.ceph.com/debian-jewel/pool/main/c/ceph-deploy/ceph-deploy_1.5.32_all.deb -O /var/cache/apt/archives/ceph-deploy_1.5.32_all.deb
dpkg -i /var/cache/apt/archives/ceph-deploy_1.5.32_all.deb
#sudo apt-get install ceph-deploy
