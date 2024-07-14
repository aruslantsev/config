#!/bin/sh
pushd /var/tmp/portage > /dev/null
while true
 do clear
 echo Now emerging
 echo ==========================================================================
 echo
 ps a | grep -i sandbox | grep -i portage | grep -v grep | awk '{print $5}' | grep --color=never -i \- | sed -e 's/\[//g' -e 's/\]//g'
 echo
 echo ==========================================================================
 echo
 echo Directories in /var/tmp/portage
 echo ==========================================================================
 echo
 find /var/tmp/portage -maxdepth 2 -type d | sed -e 's/\.\///g' | grep -i \/ --color=never | grep -v lockfile
 echo
 echo ==========================================================================
 echo
 date
 uptime
 uname -srvo
 echo 'Temperature'
#  echo -n 'Temp 1      '
#  sensors 2> /dev/null | grep -i temp1 --color=never | awk '{printf $2}'; echo
 echo -n 'Fan 1       '
 sensors 2> /dev/null | grep -i cpu_fan --color=never | awk '{printf $2}'; echo
 echo -n 'Core 0      '
 sensors 2> /dev/null | grep -i 'Core 0' --color=never | awk '{printf $3}'; echo
 echo -n 'Core 1      '
 sensors 2> /dev/null | grep -i 'Core 1' --color=never | awk '{printf $3}'; echo
 echo -n 'Core 2      '
 sensors 2> /dev/null | grep -i 'Core 2' --color=never | awk '{printf $3}'; echo
 echo -n 'Core 3      '
 sensors 2> /dev/null | grep -i 'Core 3' --color=never | awk '{printf $3}'; echo
 sleep 15
done
popd > /dev/null
