#!/bin/bash
while true
do 
date >> stats
./smart_powersave.sh /dev/sda | grep STANDBY >> stats
./smart_powersave.sh /dev/sdb | grep STANDBY >> stats
sleep 3600
done
