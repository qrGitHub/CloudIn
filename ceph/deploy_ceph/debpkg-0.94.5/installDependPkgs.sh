#!/bin/bash

doCommand() {
	echo "^_^ doCommand: $*"
	eval "$@"
	[ $? -eq 0 ] || exit 1
}

cd dependPkgs

doCommand dpkg -i libcrypto++9_5.6.1-6+deb8u1build0.14.04.1_amd64.deb
doCommand dpkg -i liburcu1_0.7.12-0ubuntu2_amd64.deb
doCommand dpkg -i liblttng-ust-ctl2_2.4.0-4ubuntu1_amd64.deb
doCommand dpkg -i liblttng-ust0_2.4.0-4ubuntu1_amd64.deb
doCommand dpkg -i gcc-4.8-base_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libstdc++6_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libc6_2.19-0ubuntu6.6_amd64.deb
doCommand dpkg -i libaio1_0.3.109-4_amd64.deb
doCommand dpkg -i libasan0_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libatomic1_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libboost-atomic1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-system1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-chrono1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-date-time1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-program-options1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-serialization1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-thread1.54.0_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libgmp10_2%3a5.1.3+dfsg-1ubuntu1_amd64.deb
doCommand dpkg -i libisl10_0.12.2-1_amd64.deb
doCommand dpkg -i libcloog-isl4_0.18.2-1_amd64.deb
doCommand dpkg -i libgomp1_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libicu52_52.1-3ubuntu0.4_amd64.deb
doCommand dpkg -i libitm1_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libsnappy1_1.1.0-1ubuntu1_amd64.deb
doCommand dpkg -i libleveldb1_1.15.0-2_amd64.deb
doCommand dpkg -i libmpfr4_3.1.2-1_amd64.deb
doCommand dpkg -i libquadmath0_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libtsan0_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libunwind8_1.1-2.2ubuntu3_amd64.deb
doCommand dpkg -i libbabeltrace1_1.2.1-2_amd64.deb
doCommand dpkg -i libbabeltrace-ctf1_1.2.1-2_amd64.deb
doCommand dpkg -i libjemalloc1_3.5.1-2_amd64.deb
doCommand dpkg -i libmpc3_1.0.1-1ubuntu1_amd64.deb
doCommand dpkg -i binutils_2.24-5ubuntu14_amd64.deb
doCommand dpkg -i cpp-4.8_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i cpp_4%3a4.8.2-1ubuntu6_amd64.deb
doCommand dpkg -i libcryptsetup4_2%3a1.6.1-1ubuntu1_amd64.deb
doCommand dpkg -i cryptsetup-bin_2%3a1.6.1-1ubuntu1_amd64.deb
doCommand dpkg -i libgcc-4.8-dev_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i gcc-4.8_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i gcc_4%3a4.8.2-1ubuntu6_amd64.deb
doCommand dpkg -i libc-dev-bin_2.19-0ubuntu6.6_amd64.deb
doCommand dpkg -i linux-libc-dev_3.13.0-68.111_amd64.deb
doCommand dpkg -i libc6-dev_2.19-0ubuntu6.6_amd64.deb
doCommand dpkg -i libstdc++-4.8-dev_4.8.4-2ubuntu1~14.04_amd64.deb
doCommand dpkg -i libboost1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-atomic1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-chrono1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-serialization1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-date-time1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-program-options1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-program-options-dev_1.54.0.1ubuntu1_amd64.deb
doCommand dpkg -i libboost-system1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-system-dev_1.54.0.1ubuntu1_amd64.deb
doCommand dpkg -i libboost-thread1.54-dev_1.54.0-4ubuntu3.1_amd64.deb
doCommand dpkg -i libboost-thread-dev_1.54.0.1ubuntu1_amd64.deb
doCommand dpkg -i libfcgi0ldbl_2.4.0-8.1ubuntu5_amd64.deb
doCommand dpkg -i libtcmalloc-minimal4_2.1-2ubuntu1.1_amd64.deb
doCommand dpkg -i libgoogle-perftools4_2.1-2ubuntu1.1_amd64.deb
doCommand dpkg -i libunwind8-dev_1.1-2.2ubuntu3_amd64.deb
doCommand dpkg -i libgoogle-perftools-dev_2.1-2ubuntu1.1_amd64.deb
doCommand dpkg -i libjs-jquery_1.7.2+dfsg-2ubuntu1_all.deb
doCommand dpkg -i libleveldb-dev_1.15.0-2_amd64.deb
doCommand dpkg -i manpages-dev_3.54-1ubuntu1_all.deb
doCommand dpkg -i python-blinker_1.3.dfsg1-1ubuntu2_all.deb
doCommand dpkg -i python-werkzeug_0.9.4+dfsg-1.1ubuntu2_all.deb
doCommand dpkg -i python-markupsafe_0.18-1build2_amd64.deb
doCommand dpkg -i python-jinja2_2.7.2-2_all.deb
doCommand dpkg -i python-itsdangerous_0.22+dfsg1-1build1_all.deb
doCommand dpkg -i python-flask_0.10.1-2build1_all.deb
doCommand dpkg -i python-pyinotify_0.9.4-1build1_all.deb
doCommand dpkg -i xfsprogs_3.1.9ubuntu2_amd64.deb
doCommand dpkg -i xml2_0.4-3.1_amd64.deb
doCommand dpkg -i gdisk_0.8.8-1ubuntu0.1_amd64.deb
