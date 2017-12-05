#!/bin/bash

# zone 2
#/root/.oss/bin/python hotlink.py | sed 's/172.16.1.4/123.59.214.172/'

# zone 3
/root/.oss/bin/python hotlink.py | sed 's/172.16.1.4:7480/123.59.184.239:10004/'
#/root/.oss/bin/python hotlink.py public-read
#/root/.oss/bin/python hotlink.py private
