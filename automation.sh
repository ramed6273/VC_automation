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

# network file
NETWORKFILE="/root/automation/00-installer-config.yaml"

sed -E 's/- [0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}\//- '"$IPV4"'\//' $NETWORKFILE
sed -E 's/\/[0-9]{2}/\/'"$SUBNET"'/' $NETWORKFILE
sed -E 's/via: [0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/via: '"$GATE4"'/' $NETWORKFILE
#cat $NETWORKFILE

#echo "network:" > $NETWORKFILE
#echo "    version: 2" >> $NETWORKFILE
#echo "    renderer: networkd" >> $NETWORKFILE
#echo "    ethernets:" >> $NETWORKFILE
#echo "        ens160:" >> $NETWORKFILE
#echo "            dhcp4: no" >> $NETWORKFILE
#echo "            dhcp6: no" >> $NETWORKFILE
#echo "            addresses:" >> $NETWORKFILE
#echo "              - ""$IPV4""/25" >> $NETWORKFILE
#echo "            nameservers:" >> $NETWORKFILE
#echo "                addresses:" >> $NETWORKFILE 
#echo "                    - 1.1.1.1" >> $NETWORKFILE 
#echo "                    - 8.8.8.8" >> $NETWORKFILE 
#echo "            routes:" >> $NETWORKFILE 
#echo "              - to: default" >> $NETWORKFILE 
#echo "                via: 217.138.215.67" >> $NETWORKFILE 

# restarting network
netplan apply

# ping gate to find route
ping -c 10 $GATE4

# check internet connection
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
	echo "VM IS ONLINE"
else
	shutdown -h now
fi

# create ssh key file
rm -f /root/.ssh/authorized_keys
touch /root/.ssh/authorized_keys
echo $SSH_PUB > /root/.ssh/authorized_keys

# deleting XML file
rm -f $TMPXML

# rebooting
sleep 5
#reboot
