#!/bin/bash

doCommand() {
    echo "^_^ doCommand: $*"
    eval "$*"
    [ ${PIPESTATUS[0]} -eq 0 ] || exit 1
}

EXIT() {
    [ $# -ne 0 ] && [ "$1" != "" ] && printf "$1\n"
    exit 1
}

string2array() {
    local OLD_IFS="$IFS"
    IFS="$2"
    local array=($1)
    IFS="$OLD_IFS"

    echo ${array[@]}
}

create_conf() {
    if [ $# -ne 1 ]; then
        printf "Monitor ip is needed for 'conf' command\n"
        exit 1
    fi

    doCommand cp deploy.conf.sample $ceph_conf

    doCommand "sed -i 's/<UUID>/'$(uuidgen)'/g' $ceph_conf"
    doCommand "sed -i 's/<HOST_NAME>/'$(hostname)'/g' $ceph_conf"
    doCommand "sed -i 's/<MONITOR_IP>/'${1}'/g' $ceph_conf"
}

# Prepare something for ceph
prepare_misc() {
    doCommand groupadd -g 64045 ceph
    doCommand useradd -u 64045 ceph -g ceph
    doCommand mkdir -p           /var/lib/ceph/ /etc/ceph/ /var/run/ceph/ /var/log/ceph
    doCommand chown -R ceph:ceph /var/lib/ceph/ /etc/ceph/ /var/run/ceph/ /var/log/ceph

    doCommand ln -s /usr/local/lib/libradosstriper.so.1 /usr/lib/libradosstriper.so.1
    doCommand ln -s /usr/local/lib/libcephfs.so.2 /usr/lib/libcephfs.so.2
    doCommand ln -s /usr/local/lib/librados.so.2 /usr/lib/librados.so.2
}

# Create the first monitor
create_monitor() {
    # Create a keyring for the cluster and generate a monitor secret key.
    ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
    [ $? -eq 0 ] || EXIT "Create monitor key FAILED!"

    # Generate an administrator keyring, generate a client.admin user and add the user to the keyring.
    sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key \
        -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
    [ $? -eq 0 ] || EXIT "Create administrator key FAILED!"

    # Add the client.admin key to the ceph.mon.keyring.
    doCommand ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

    # Generate a monitor map.
    [ -f /tmp/monmap ] && rm -f /tmp/monmap
    doCommand monmaptool --create --add ${mon_name} ${mon_addr} --fsid ${fsid} /tmp/monmap

    # Create a data directory on the monitor host.
    doCommand sudo mkdir -p ${mon_dir}

    # Populate the monitor daemon with the monitor map and keyring.
    doCommand sudo ceph-mon --cluster ${cluster} --mkfs -i ${mon_name} \
        --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

    # Mark that the monitor is created and ready to be started
    doCommand sudo touch ${mon_dir}/done

    # Change the owner of monitor directory
    doCommand sudo chown -R ceph:ceph ${mon_dir}

    # Start the monitor
    doCommand ceph-mon --cluster="${cluster:-ceph}" -i "${mon_name}" --setuser ceph --setgroup ceph
}

# Create a mgr(Luminous need this)
create_mgr() {
    local mgr_name=$mon_name
    local mgr_dir=/var/lib/${cluster}/mgr/${cluster}-${mgr_name}
    local key_path=${mgr_dir}/keyring

    # Create a data directory on the mgr host.
    doCommand mkdir -p ${mgr_dir}

    # Create an authentication key for mgr daemon
    ceph auth get-or-create mgr.${mgr_name} mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o ${key_path}

    # Change the owner of mgr directory
    doCommand sudo chown -R ceph:ceph $mgr_dir

    # Start the mgr
    doCommand ceph-mgr --cluster="${cluster:-ceph}" -i "${mgr_name}" --setuser ceph --setgroup ceph
}

add_osd() {
    local device="$1"
    local weight="$2"
    local bucket="$3"

    # Create a OSD
    local osd_id=$(ceph osd create)
    local osd_dir=/var/lib/ceph/osd/${cluster}-${osd_id}

    # Create the default directory for the OSD.
    doCommand sudo mkdir -p ${osd_dir}

    doCommand sudo mkfs.xfs -f ${device}
    doCommand sudo mount -o ${mount_options} ${device} ${osd_dir}

    # Initialize the OSD data directory.
    doCommand sudo ceph-osd -i ${osd_id} --mkfs --mkkey

    # Register the OSD authentication key.
    doCommand sudo ceph auth add osd.${osd_id} osd \'allow *\' mon \'allow rwx\' -i ${osd_dir}/keyring

    # Add your Ceph Node to the CRUSH map.
    doCommand sudo ceph --cluster ${cluster} osd crush add ${osd_id} ${weight} ${bucket}

    doCommand sudo touch ${osd_dir}/upstart

    # Change the owner of osd directory
    doCommand sudo chown -R ceph:ceph ${osd_dir}

    doCommand ceph-osd --cluster="${cluster:-ceph}" -i ${osd_id} --setuser ceph --setgroup ceph
}

check_device_status() {
    for dev in $@
    do
        lsof $dev > /dev/null
        if [ $? -eq 0 ]; then
            printf "Device %s has open files, cannot use it directly\n" $dev
            return 1
        fi
    done

    return 0
}

create_osd_from_conf() {
    local dev_list dev_array dev_size weight
    dev_list=$(awk -F= '/osd.'$mon_name'.devs/{print $NF}' $ceph_conf)
    dev_array=$(string2array "$dev_list" ",")

    check_device_status ${dev_array[@]}
    if [ $? -ne 0 ]; then
        return 1
    fi

    for dev in ${dev_array[@]}
    do
        dev_size=$(blockdev --getsize64 $dev)
        if [ $? -ne 0 ]; then
            printf "Find size for device %s failed\n" $dev
            return 1
        fi

        weight=$(echo $dev_size | awk '{printf "%0.2f\n", $1/1099511627776}')
        add_osd $dev $weight "root=default host=$mon_name"
    done
}

adjust_crushmap() {
    local bin_file=/tmp/bin.crushmap txt_file=/tmp/txt.crushmap

    echo "Change host to osd for replicated_rule"
    doCommand ceph osd getcrushmap -o $bin_file
    doCommand crushtool -d $bin_file -o $txt_file
    sed -i 's/\(step chooseleaf firstn 0 type\).*/\1 osd/' $txt_file
    doCommand crushtool -c $txt_file -o $bin_file
    doCommand ceph osd setcrushmap -i $bin_file
}

ceph_conf=/etc/ceph/ceph.conf
if [ -f $ceph_conf ]; then
    mount_options=$(awk '/osd_mount_options_xfs/{print $NF}' $ceph_conf)
    mon_name=$(awk '/mon_initial_members/{print $NF}' $ceph_conf)
    mon_addr=$(awk '/mon_host/{print $NF}' $ceph_conf)
    fsid=$(awk '/fsid/{print $NF}' $ceph_conf)
    cluster=ceph
    
    mon_dir=/var/lib/ceph/mon/${cluster}-${mon_name}
fi

case $1 in
    misc)
        prepare_misc
        ;;
    conf)
        shift
        create_conf $@
        ;;
    mon)
        create_monitor
        ;;
    mgr)
        create_mgr
        ;;
    osd)
        create_osd_from_conf
        ;;
    map)
        adjust_crushmap
        ;;
    *)
        printf "Usage:\n\tbash %s <misc|conf|mon|osd|map> [<arg>...]\n" "$0"
        printf "Example:\n"
        printf "\tbash %s misc\n" "$0"
        printf "\tbash %s conf <monitor ip>\n" "$0"
        printf "\tbash %s mon\n" "$0"
        printf "\tbash %s mgr (Luminous)\n" "$0"
        printf "\tbash %s osd\n" "$0"
        printf "\tbash %s map\n" "$0"
        exit 1
esac
