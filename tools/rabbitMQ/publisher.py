#!/usr/bin/env python
#-*- coding:utf-8 -*-

from kombu.pools import producers
from kombu import Exchange, Queue
from kombu import Connection

import sys

def send_as_task(connection, payload):
    with producers[connection].acquire(block = True) as producer:
        producer.publish(payload,
                         serializer = 'json',
                         #compression='bzip2',
                         exchange = task_exchange,
                         declare = [task_exchange],
                         routing_key = 'devops')

if __name__ == '__main__':
    connection = Connection('amqp://openstack:123QAZqaz@10.1.9.3:5672//')
    task_exchange = Exchange('tasks', type = 'direct')
    task_queue = Queue('devops', task_exchange, routing_key = 'devops')
    payload = {
            'cmd_id': sys.argv[1],
            'ret_code': sys.argv[2],
            'message': sys.argv[3]
            }
    send_as_task(connection, payload)
