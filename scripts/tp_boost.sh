#!/bin/bash

# Checking root user
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# Checking current state
if [ `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` = 'userspace' ]
then
	# Lowest speed and ondemand governor for all cores
	for CPU in /sys/devices/system/cpu/*/cpufreq/
	do
  	  echo `cat ${CPU}cpuinfo_min_freq` | tee ${CPU}scaling_setspeed
			echo ondemand | tee ${CPU}scaling_governor
	done
	# Automatic fan control
	echo level auto | tee /proc/acpi/ibm/fan 
else
	# Otherwise full fan speed
	echo level full-speed | tee /proc/acpi/ibm/fan
	# And full speed for all cores
	for CPU in /sys/devices/system/cpu/*/cpufreq/
	do
			echo userspace | tee ${CPU}scaling_governor
  	  echo `cat ${CPU}cpuinfo_max_freq` | tee ${CPU}scaling_setspeed
	done
fi
TEMP=$((`cat /sys/class/thermal/thermal_zone0/temp`/1000))
echo "CPU Temp: ${TEMP}C"

# Developed by gear. You can contact me by misty.g3ar@gmail.com


