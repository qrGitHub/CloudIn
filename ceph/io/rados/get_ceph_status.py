#!/usr/bin/env python
#-*- coding:utf-8 -*-

import rados
import json

def get_cluster_health(cluster):
    cmd = {
            "prefix": "status",
            "format": "json"
    }
    ret, buf, errs = cluster.mon_command(json.dumps(cmd), b'', timeout=5)
    result = json.loads(buf)

    return result['health']['overall_status']

with rados.Rados(conffile='/etc/ceph/ceph.conf', name='client.admin',
        conf=dict(keyring='/etc/ceph/ceph.client.admin.keyring')) as cluster:
    print get_cluster_health(cluster)
