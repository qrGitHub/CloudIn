#!/usr/bin/env python
#-*- coding:utf-8 -*-

import time, sys, stomp

conn = stomp.Connection(host_and_ports = [('localhost', 61613)])
conn.start()
conn.connect('qr_admin', '1qaz2wsx$RFV', wait = True)

conn.send(body = ' '.join(sys.argv[1:]), destination = '/queue/qr_test')

time.sleep(1)

conn.disconnect()
