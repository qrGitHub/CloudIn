#! /bin/bash
# for ubuntu

### Diamond
function install_diamond_deps()
{
    apt-get install -y make pbuilder python-mock python-configobj python-support cdbs
    pip install configobj
}

function install_diamond()
{
    install_diamond_deps

    cd $exec_dir
    dpkg -i diamond_3.4.582_all.deb
    if [ $? -ne 0 ]; then
        cd Diamond;
        make builddeb
        dpkg -i build/diamond_*all.deb
    fi

    cp $exec_dir/Diamond/conf/diamond.conf /etc/diamond/
    # change ip to the configure ip
    cmd="sed -i 's/223.202.11.141/$graphite_ip/g' /etc/diamond/diamond.conf"
    eval $cmd

    # Add diamond sudo NOPASSWD auth
    echo "diamond ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers

    service diamond start
}

### Graphite
function install_graphite_deps()
{
    apt-get install -y python-dev python-cairo-dev libffi-dev
    pip install cairocffi
}

function install_graphite()
{
    install_graphite_deps

    cd $exec_dir
    pip install carbon
    pip install whisper
    pip install graphite-web
    pip install django
    pip install django-tagging

    cd /opt/graphite/conf
    cp aggregation-rules.conf.example aggregation-rules.conf
    cp blacklist.conf.example blacklist.conf
    cp carbon.conf.example carbon.conf
    cp carbon.amqp.conf.example carbon.amqp.conf
    cp relay-rules.conf.example relay-rules.conf
    cp rewrite-rules.conf.example rewrite-rules.conf 
    cp storage-schemas.conf.example storage-schemas.conf 
    cp storage-aggregation.conf.example storage-aggregation.conf 
    cp whitelist.conf.example whitelist.conf

    # Change storage schemas to keep 7days records
    sed -i 's/default_1min_for_1day/default_1min_for_7day/g' /opt/graphite/conf/storage-schemas.conf
    sed -i 's/retentions = 60s:1d/retentions = 60s:7d/g' /opt/graphite/conf/storage-schemas.conf

    # Change the carbon MAX configurations in carbon.conf
    sed -i 's/MAX_UPDATES_PER_SECOND = 500/MAX_UPDATES_PER_SECOND = 30000/g' /opt/graphite/conf/carbon.conf
    sed -i 's/MAX_CREATES_PER_MINUTE = 50/MAX_CREATES_PER_MINUTE = 1000/g' /opt/graphite/conf/carbon.conf

    # start carbon daemon
    cd /opt/graphite/bin
    ./carbon-cache.py start

    cd /opt/graphite
    export PYTHONPATH=$PYTHONPATH:`pwd`/webapp
    django-admin.py syncdb --settings=graphite.settings

    cd /opt/graphite
    PYTHONPATH=`pwd`/storage/whisper ./bin/run-graphite-devel-server.py --port=8085 --libs=`pwd`/webapp /opt/graphite 1>/opt/graphite/storage/log/webapp/process.log 2>&1 &
}

### Grafana
function install_grafana_deps()
{
    apt-get install -y adduser libfontconfig
}

function install_grafana()
{
    install_grafana_deps

    cd $exec_dir
    dpkg -i grafana_4.4.1_amd64.deb
    service grafana-server start
}

function usage()
{
    echo "usage: $1             # just deploy diamond on this host"
    echo "       $1 graphite    # deploy graphite on this host"
    echo "       $1 grafana     # deploy graphite and grafana on this host"
}


graphite_ip="172.16.0.5"

### main entrance
script_name=$0
exec_dir=`pwd`
if [[ $# == 0 ]]; then
    install_diamond
elif [[ $# == 1 ]]; then
    option=$1
    if [[ $option == "graphite" ]]; then
        install_graphite
    elif [[ $option == "grafana" ]]; then
        install_graphite
        install_grafana
    else
        usage $script_name
        exit
    fi
else
    usage $script_name
    exit
fi

