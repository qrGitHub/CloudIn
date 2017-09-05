#!/usr/bin/env python
#-*- coding:utf-8 -*-

from javax.jms import Session
from org.apache.activemq import ActiveMQConnectionFactory

connFactory = ActiveMQConnectionFactory()

conn = connFactory.createConnection()

sess = conn.createSession(False, Session.AUTO_ACKNOWLEDGE)

dest = sess.createQueue('qr_test')

cons = sess.createConsumer(dest)

conn.start()

msg = cons.receive()

print(msg)

conn.close()
