#!/usr/bin/env python
#-*- coding:utf-8 -*-

import rados, rbd

def rbd_create_and_write(pool_name, image_name, image_size, offset, data,
                         conffile = '/etc/ceph/ceph.conf'):
    with rados.Rados(conffile = conffile) as cluster:
        if not cluster.pool_exists(pool_name):
            raise RuntimeError('Pool %s not exist' % pool_name)
        with cluster.open_ioctx(pool_name) as ioctx:
            rbd_inst = rbd.RBD()
            rbd_inst.create(ioctx, image_name, image_size)
            with rbd.Image(ioctx, image_name) as image:
                image.write(data, offset)

def rbd_pool_is_empty(pool_name, conffile = '/etc/ceph/ceph.conf'):
    with rados.Rados(conffile = conffile) as cluster:
        if not cluster.pool_exists(pool_name):
            return True

        with cluster.open_ioctx(pool_name) as ioctx:
            rbd_inst = rbd.RBD()
            return False if len(rbd_inst.list(ioctx)) else True

    return False

if __name__ == "__main__":
    rbd_create_and_write('rbd', 'test', 4 * 1024**3, 0, 'foo' * 200)
