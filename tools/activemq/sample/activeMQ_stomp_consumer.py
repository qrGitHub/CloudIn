#!/usr/bin/env python
#-*- coding:utf-8 -*-

import stomp

class SampleListener(stomp.ConnectionListener):
    def on_error(self, headers, message):
        print('received an error "%s"' % message)

    def on_message(self, headers, message):
        print('received a message "%s" (%s)' % (message, headers))

def listen():
    # create a connection
    conn = stomp.Connection(host_and_ports = [('localhost', 61613)])

    # setup the listener for messages
    conn.set_listener('SampleListener', SampleListener())

    conn.start()
    conn.connect('qr_admin', '1qaz2wsx$RFV', wait = True)

    # subscribe a topic, autoconfirmed
    conn.subscribe(destination = '/queue/qr_test', id = 1, ack = 'auto')
    #conn.subscribe(destination = '/queue/qr_test', id = 1, ack = 'client')

    conn.disconnect()

listen()
