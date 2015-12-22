#!/bin/bash
# For Ubuntu 14.04 only

usage() {
    printf "Usage:\n\tbash $0 --calamariServer | { --cephNode --calamariServerIP IPv4 } | -h\n"
    printf "Example:\n\tbash $0 --cephNode --calamariServerIP 192.168.1.1\n"
    printf "\tbash $0 --calamariServer\n"
    printf "\tbash $0 -h\n"

    exit $1
}

EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

installSaltMaster() {
    cd server/salt
    bash install.sh -s
    cd - > /dev/null
}

installCalamariDeps() {
    doCommand "sudo apt-get update && sudo apt-get install -y apache2 libapache2-mod-wsgi libcairo2 supervisor python-cairo libpq5 postgresql python-sqlalchemy python-mako python-gevent python-twisted python-txamqp python-greenlet"
}

installCalamari() {
    installCalamariDeps

    doCommand sudo dpkg -i ./server/calamari-server_1.3.1.1-1trusty_amd64.deb
    doCommand sudo dpkg -i ./server/calamari-clients_1.3.1.1-1trusty_all.deb
}

configCalamari() {
    doCommand sudo calamari-ctl initialize
    doCommand sudo chmod -R a+w /var/log/calamari
}

installDiamondDeps() {
    doCommand sudo apt-get install -y python-support
}

installDiamond() {
    installDiamondDeps

    doCommand sudo dpkg -i client/diamond_3.4.67_all.deb
    doCommand cp /etc/diamond/diamond.conf{.example,}
    doCommand "sed -i -e \":begin; /# Graphite server host/,/host =/ { /host =/! { \$! { N; b begin }; }; s/host =.*$/host = $calamariServerIP/g; };\" /etc/diamond/diamond.conf"
    doCommand service diamond restart
}

installSaltMinion() {
    cd client/salt
    bash install.sh -c
    cd - > /dev/null
}

configSaltMinion() {
    doCommand "sudo echo \"master: $calamariServerIP\" > /etc/salt/minion.d/calamari.conf"
    doCommand sudo service salt-minion restart
    #sudo service diamond restart
}

deployCalamariServer() {
    installSaltMaster
    installCalamari
    configCalamari
}

deployCephNode() {
    installDiamond
    installSaltMinion
    configSaltMinion
}

#<=============================================================================
# Process arguments start
TEMP=`getopt -o h --longoptions calamariServer,cephNode,calamariServerIP:,help -n "$0" -- "$@"`
if [ $? -ne 0 ]; then echo "Terminating..." >&2; exit 1; fi

eval set -- "$TEMP"
while true
do
    case "$1" in
        -h | --help)
            helpFlag=1
            shift
            ;;
        --calamariServer)
            calamariServerFlag=1
            shift
            ;;
        --cephNode)
            cephNodeFlag=1
            shift
            ;;
        --calamariServerIP)
            calamariServerIP=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
    esac
done

if [ $helpFlag ]; then
    usage 0
fi

if [[ $calamariServerFlag && $cephNodeFlag ]]; then
    EXIT "Option --calamariServer and --cephNode are alternative"
fi

if [[ ! $calamariServerFlag && ! $cephNodeFlag ]]; then
    EXIT "Option --calamariServer or --cephNode is missing"
fi

if [[ $cephNodeFlag && ! $calamariServerIP ]]; then
    EXIT "Option --calamariServerIP must be specified for option --cephNode"
fi

if [ $# -ne 0 ]; then
    EXIT "Parameter '$*' is not needed!"
fi
# Process arguments end
#=============================================================================>

if [ $calamariServerFlag ]; then
    deployCalamariServer
fi

if [ $cephNodeFlag ]; then
    deployCephNode
fi
