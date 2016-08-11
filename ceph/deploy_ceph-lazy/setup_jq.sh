#!/bin/bash

git clone https://github.com/stedolan/jq.git
cd jq/
autoreconf -i
./configure
make -j8
make check
