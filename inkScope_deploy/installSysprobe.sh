echo deb https://raw.githubusercontent.com/inkscope/inkscope-packaging/master/DEBS ./ > /etc/apt/sources.list.d/inkscope.list
sudo apt-get update 
sudo apt-get install -y python-pip

sudo apt-get install -y python-dev
pip install psutil==2.1.3
sudo apt-get install inkscope-sysprobe
sudo apt-get install -y lshw
sudo apt-get install -y sysstat
vim /opt/inkscope/etc/inkscope.conf
/etc/init.d/sysprobe start

#chmod a+r /opt/inkscope/etc/inkscope.conf
#pip install pymongo
