#!/bin/bash

saltCommonDebName=salt-common_2014.7.0+ds-2~bpo70+1_all.deb
saltMinionDebName=salt-minion_2014.7.0+ds-2~bpo70+1_all.deb
saltMasterDebName=salt-master_2014.7.0+ds-2~bpo70+1_all.deb
saltSyndicDebName=salt-syndic_2014.7.0+ds-2~bpo70+1_all.deb

usage() {
    printf "Usage:\n\t$0 [-c]|[-s]\n"
}

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$@"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

downloadDebPackages() {
    if [ ! -f $saltCommonDebName ]; then
        doCommand wget http://debian.saltstack.com/debian/pool/main/s/salt/$saltCommonDebName
    fi

    if [ ! -f $saltMinionDebName ]; then
        doCommand wget http://debian.saltstack.com/debian/pool/main/s/salt/$saltMinionDebName
    fi

    if [ $1 -eq 1 ] && [ ! -f $saltMasterDebName ]; then
        doCommand wget http://debian.saltstack.com/debian/pool/main/s/salt/$saltMasterDebName
    fi

    if [ $1 -eq 1 ] && [ ! -f $saltSyndicDebName ]; then
        doCommand wget http://debian.saltstack.com/debian/pool/main/s/salt/$saltSyndicDebName
    fi
}

setupSalt() {
    doCommand sudo apt-get install -y python-yaml python-m2crypto python-crypto python-msgpack python-zmq dctrl-tools
    doCommand sudo dpkg -i $saltCommonDebName
    doCommand sudo dpkg -i $saltMinionDebName
    [ $1 -eq 0 ] || doCommand sudo dpkg -i $saltMasterDebName
    [ $1 -eq 0 ] || doCommand sudo dpkg -i $saltSyndicDebName
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

if [ $1 = "-c" ]; then
    downloadDebPackages 0
    setupSalt 0
elif [ $1 = "-s" ]; then
    downloadDebPackages 1
    setupSalt 1
else
    usage
    exit 1
fi
