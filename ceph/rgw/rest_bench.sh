#!/bin/bash

RGW=123.59.26.133:7480
SECS=10
SIZE=$((1<<22)) # 4MB object size
BUCKET=restBench
CONCURRENCY=16
KEY=N8JYDX1HCAM55XDWGL10
SECRET=uRpR6EbR9YkyjfvdQmuJq0VgEx1a0KONl0NCKlJ9

rest-bench -t $CONCURRENCY -b $SIZE --seconds=$SECS --api-host=$RGW --bucket=$BUCKET --access-key=$KEY --secret=$SECRET --no-cleanup write
