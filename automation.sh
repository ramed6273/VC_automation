#!/bin/bash

# creating XML file from VMapp
vmtoolsd --cmd "info-get guestinfo.ovfenv" > /tmp/ovf_env.xml
TMPXML='/tmp/ovf_env.xml'

# getting variables from XML 

#IPV4
IPV4=`cat $TMPXML| grep -e IPV4 |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`
GATE4=`cat $TMPXML| grep -e GATE4 |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`
SUBNET4=`cat $TMPXML| grep -e SUBNET4 |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`

# IPV6
IPV6=`cat $TMPXML| grep -e IPV6 |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`
GATE6=`cat $TMPXML| grep -e GATE6 |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`
SUBNET6=`cat $TMPXML| grep -e SUBNET6 |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`

# hostname
HOSTNAME=`cat $TMPXML| grep -e HOSTNAME |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`

# ssh public key
SSH_PUB=`cat $TMPXML| grep -e SSH_PUB |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`

PASSWORD=`cat $TMPXML| grep -e PASSWORD |sed -n -e '/value\=/ s/.*\=\" *//p'|sed 's/\"\/>//'`

# network file
NETWORKFILE="/root/automation/00-installer-config.yaml"

sed -i "s/IPv4/$IPV4/" $NETWORKFILE
sed -i "s/IPv6/$IPV6/" $NETWORKFILE
sed -i "s/SUBNET4/$SUBNET4/" $NETWORKFILE
sed -i "s/SUBNET6/$SUBNET6/" $NETWORKFILE
sed -i "s/GATE4/$GATE4/" $NETWORKFILE
sed -i "s/GATE6/$GATE6/" $NETWORKFILE

netplan apply

# ping gate to find route
ping -c 4 $GATE4

if [ $? -eq 0 ]
then
	echo "VM is online"
else
	echo "ss"
fi

# check internet connection
#wget -q --spider http://google.com
#if [ $? -eq 0 ]; then
#	echo "VM IS ONLINE"
#else
#	shutdown -h now
#fi

# create ssh key file
if [ $SSH_PUB ]
then	
	echo $SSH_PUB > /root/.ssh/authorized_keys
else
	echo -e "_Asampanel123\n_Asampanel123" | passwd root
fi

apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y --force-yes -fuy -o Dpkg::Optitons::='--force-confold'

# deleting XML file
rm -f $TMPXML

# rebooting
sleep 5
#reboot
