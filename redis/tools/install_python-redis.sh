#!/bin/bash

filename=redis-2.10.5
tarname=${filename}.tar.gz
wget --no-check-certificate https://pypi.python.org/packages/source/r/redis/$tarname

tar -xzf $tarname
mv $filename python-$filename
cd python-$filename
python setup.py install
