#! /usr/bin/env bash

## openvswitch version arguments
if [[ $# -ne 1 ]]
then
 echo "$0 [openvswitch_version]"
 exit
fi
current_directory=$(pwd)
openvswitch_version=$1

## remove the linux bridge for openvswitch
if [[ `lsmod | grep -i 'bridge'` ]]
then
 rmmod bridge
fi

## update the dns server for downloading process
if [[ ! `cat /etc/resolv.conf | grep -i '8.8.8.8'` ]]
then
 echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi

## installation for the basic packages
apt-get update
apt-get install -y ipsec-tools git expect python-all python-qt4 python-zopeinterface python-twisted-conch python-simplejson python-twisted-web module-assistant dpkg-dev dpkg gcc uml-utilities libtool build-essential fakeroot graphviz debhelper autoconf automake dkms libssl-dev make po-debconf gettext file debianutils binutils util-linux module-init-tools dbus pkg-config
if [[ ! -f '/etc/racoon/racoon.conf' ]]
then
 ## create the expect file for racoon installation
 file_name="$current_directory/openvswitch_racoon_installer.exp"
 touch $file_name
 chmod 777 $file_name
 echo "#! /usr/bin/expect" > $file_name
 echo "spawn bash -c \"apt-get install -y racoon\"" >> $file_name
 echo "expect -re \"<Ok>\"" >> $file_name
 echo "send \"\\r\"" >> $file_name
 echo "interact" >> $file_name
 ## run the racoon installation
 racoon_setup_run=`find / -name 'openvswitch_racoon_installer.exp'`
 $racoon_setup_run
 rm -rf $file_name
fi

## packet forward enable
sed -i 's/#[[:space:]]*net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

## decrease the fail time out
sed -i 's/[[:space:]]*sleep[[:space:]]*[0-9]*/        sleep 1/' /etc/init/failsafe.conf

## download the openvswitch tarbal and installation
if [[ ! `lsmod | grep -i 'openvswitch'` ]]
then
 wget http://openvswitch.org/releases/openvswitch-$openvswitch_version.tar.gz
 tar xvfz openvswitch-$openvswitch_version.tar.gz
 rm -rf openvswitch-$openvswitch_version.tar.gz
 cd openvswitch-$openvswitch_version
 fakeroot debian/rules binary
 cd $current_directory
 ls $current_directory/*.deb | xargs dpkg -i
 ls $current_directory/*.deb | xargs rm -rf
fi

## confirmation the installation status
echo "################ openvswitch version ##################"
echo "$(ovs-vsctl --version)"
echo "############### module status 'lsmod' #################"
echo "$(lsmod | grep -i 'openvswitch')"
echo "#######################################################"
