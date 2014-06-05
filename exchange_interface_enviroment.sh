#! /usr/bin/env bash

## openvswitch version arguments
if [[ $# -ne 1 ]]
then
 echo "$0 [interface enviornments, --help or -h to see the models]"
 exit
fi
current_directory=$(pwd)
interface_option=$1

if [ $interface_option == '-h' -o $interface_option == '--help' ]
then
 echo "###########################################"
 echo "# interface enviornments 1 ( 1 )          #"
 echo "#         (bridge) brext -- (port) brext  #"
 echo "#                        -- (port) eth0   #"
 echo "#         (bridge) brint -- (port) brint  #"
 echo "#                        -- (port) eth1   #"
 echo "###########################################"
 exit
fi

## ipcalc package installation
if [[ ! `which ipcalc` ]]
then
 apt-get install -y ipcalc
fi


if [[ $interface_option -eq 1 ]]
then
 ## get the ip address and network interface
 ## setp 1, create the bridge
 ovs-vsctl add-br brext
 ovs-vsctl add-br brint
 ## 


else
 echo "$0 [interface enviornments, --help or -h to see the models]"
 exit
fi
