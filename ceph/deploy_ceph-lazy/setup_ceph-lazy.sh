#!/bin/bash

apt-get install jq

cp ceph-lazy /usr/local/sbin/
chown root:root /usr/local/sbin/ceph-lazy
chmod u+x /usr/local/sbin/ceph-lazy 
cp bash_completion.d/ceph-lazy /etc/bash_completion.d/
