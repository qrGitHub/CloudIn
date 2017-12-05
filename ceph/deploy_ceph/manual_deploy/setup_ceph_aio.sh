# ********************************************************
# *    SETUP ALL IN ONE environment for Luminous CEPH    *
# ********************************************************
#  1 Prepare the internet
#  2 Prepare the code of CEPH
#  3 Install pip and prepare its source
#  4 cd CEPH directory: ./install-deps.sh
#  5 run the following command
         apt-get install -y autoconf automake autotools-dev pkg-config libtool libboost-dev libedit-dev libexpat1-dev libfcgi-dev libfuse-dev g++ gcc libsnappy-dev libleveldb-dev uuid-dev libblkid-dev libudev-dev libkeyutils-dev libcrypto++-dev libatomic-ops-dev libaio-dev xfslibs-dev libboost-thread-dev libboost-program-options-dev make debhelper libjemalloc-dev
#  6 cd CEPH directory: ./do_cmake.sh
#  7 cd CEPH/build: (time make -j4) 2>&1 | tee make.log
#  8 cd CEPH/build: make install
#  9 bash manually_deploy_ceph.sh misc
# 10 bash manually_deploy_ceph.sh conf <monitor ip>
# 11 verify osd device list in /etc/ceph/ceph.conf
# 12 bash manually_deploy_ceph.sh mon
# 13 bash manually_deploy_ceph.sh mgr
# 14 bash manually_deploy_ceph.sh osd
# 15 bash manually_deploy_ceph.sh map


# ************************************************************
# *    SETUP ALL IN ONE environment for Hammer/Jewel CEPH    *
# ************************************************************
#  1 Prepare the internet
#  2 Prepare the code of CEPH
#  3 Install pip and prepare its source
#  4 cd CEPH directory: ./install-deps.sh
#  5 run the following command
         apt-get install -y autoconf automake autotools-dev pkg-config libtool libboost-dev libedit-dev libexpat1-dev libfcgi-dev libfuse-dev g++ gcc libsnappy-dev libleveldb-dev uuid-dev libblkid-dev libudev-dev libkeyutils-dev libcrypto++-dev libatomic-ops-dev libaio-dev xfslibs-dev libboost-thread-dev libboost-program-options-dev make debhelper libjemalloc-dev
#  6 cd CEPH directory: ./autogen.sh
#  7 cd CEPH directory: ./configure --without-tcmalloc --with-jemalloc
#  8 cd CEPH directory: (time make -j4) 2>&1 | tee make.log
#  9 cd CEPH directory: make install
# 10 bash manually_deploy_ceph.sh misc
# 11 bash manually_deploy_ceph.sh conf <monitor ip>
# 12 verify osd device list in /etc/ceph/ceph.conf
# 13 bash manually_deploy_ceph.sh mon
# 14 bash manually_deploy_ceph.sh osd
# 15 bash manually_deploy_ceph.sh map
