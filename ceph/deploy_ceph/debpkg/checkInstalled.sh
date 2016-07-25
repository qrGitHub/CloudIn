#!/bin/bash

for pkg in $(grep "dpkgRemove " uninstall.sh | awk '{print $2}')
do
	dpkg -l | grep " $pkg "
done

for pkg in $(grep "apt-get install" prepare.sh | awk '{for(i=5; i<=NF; i++) print $i}')
do
	dpkg -l | grep " $pkg "
done
