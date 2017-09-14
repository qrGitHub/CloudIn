#!/usr/bin/env python
#-*- coding:utf-8 -*-

from kombu.messaging import Consumer
from kombu import Exchange, Queue
from kombu import Connection

def worker(body, message):
    print body
    message.ack()

if __name__ == '__main__':
    connection = Connection('amqp://localhost:5672//')
    channel = connection.channel()
    task_exchange = Exchange('tasks', type = 'direct', channel = channel)
    task_queue = Queue('devops', task_exchange, routing_key = 'devops', channel = channel)

    consumer = Consumer(channel, queues = [task_queue], callbacks = [worker])
    consumer.consume()
    while True:
        try:
            connection.drain_events()
        except KeyboardInterrupt:
            break

    consumer.cancel()
