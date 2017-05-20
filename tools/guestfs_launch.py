#!/usr/bin/env python
#-*- coding:utf-8 -*-

# **********
#   http://libguestfs.org/guestfs-faq.1.html#debugging-libguestfs
# There are two methods to enable libguestfs debug
#   1. bash method: export LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1
#   2. api method: call g.set_verbose(True) and g.set_trace(True) before the call to launch
# **********

import guestfs

diskfile = '/vms/78f5f61f-6ddc-47f6-a1e5-9205bbcf6a7f_disk'
imgfmt = 'raw'
protocol = 'rbd'
server = ['192.168.6.231:6789']
username = 'cinder'
secret = None

guest_dev = guestfs.GuestFS()
guest_dev.add_drive_opts(diskfile, format=imgfmt, protocol=protocol,server=server, username=username, secret=secret)

guest_dev.set_verbose(True);
guest_dev.set_trace(True);

guest_dev.launch()
