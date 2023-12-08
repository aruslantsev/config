#!/bin/sh
# test-sleep-battery-usage.sh
# test script for measuring power drain during suspend-to-ram with ACPI
# you should carefully read through this script and make adjustments as necessary before running it!
# http://www.thinkwiki.org/wiki/ACPI_sleep_power_drain_test_script

# written for linux kernel 2.6.38, with older kernel options that you can uncomment if needed
# as far as I know, this script contains only one non-POSIX command: date +%s

# uncomment and/or change the following parameters if you need to pass them to pm-suspend
# pm_params="--quirk-s3-bios --quirk-s3-mode"
# Refer to http://www.thinkwiki.org/wiki/Problem_with_display_remaining_black_after_resume

# if you have two batteries, you should take one out (and adjust the battery variable) in order to get an accurate reading
battery=BAT0

# paths and energy/status functions - these work for linux kernels 2.6.25 through 3.2 and beyond
battery_dir=/sys/class/power_supply/$battery
get_energy () { cat $battery_dir/energy_now; }
get_status () { cat $battery_dir/status; }
discharging_string="Discharging"

# /proc/acpi/battery was deprecated somewhere in the era of linux kernel 2.6.24
# if you are using such an old kernel that does not have /sys/class/power_supply, you can uncomment these lines:
# battery_dir=/proc/acpi/battery/$battery
# get_energy () { grep 'remaining capacity' $battery_dir/state | awk '{print $3}'; }
# get_status () { grep '^charging state:' $battery_dir/state | awk '{print $3}'; }
# discharging_string="discharging"

# suspend command
# suspend_func () { pm-suspend $pm_params; }
suspend_func () { echo mem > /sys/power/state; echo $pm_params; }

# here is an older version of the suspend command; you can uncomment it if you want to use it
# suspend_func () {
# if [ -e /proc/acpi/sleep ]; then
#   echo 3 > /proc/acpi/sleep
# else
#   echo -n mem > /sys/power/state
# fi
# }

# different kernels and different hardware report energy values using different units
# energy values should typically be in the range of 15 - 75 Wh (Watt-hours, or Ah, Amp-hours. Whatever :-)
# get an energy value from $energy_file, divide by the power_divider, and see what you get...
# if yours is 2.5 or 250 rather than 25, adjust the divider
power_divider=1000000 # micro watt hours / μWh
# power_divider=1000 # milli watt hours / mWh
# power_divider=100 # centi watt hours / cWh

warning_threshold=0.8 # watts above which we give a warning

logfile=/var/log/battery-test.log

# it is easier to do copy/paste script tests if failures don't exit the shell :-)
do_exit () { exit $1; }

# the sed function strips trailing zeros off of the bc result, e.g. 14.50000000000 -> 14.5  (but 0 -> 0)
calcfunc () { echo "$@" | bc -l | sed '/^0$/!s,0*$,,'; }
# a creative way to compare floating point numbers...
a_less_than_b () { case $(echo "$1-$2" | bc) in -*) return 0;; *) return 1;; esac; }

which bc >/dev/null || { echo "I need 'bc' to do floating point operations. install it, or change the functions 'calcfunc' and 'a_less_than_b'"; do_exit 1; }

test_energy=$(calcfunc $(get_energy)/$power_divider)
if a_less_than_b $test_energy 10; then
  warn_pwr="less than 10 watt-hours"
elif a_less_than_b 100 $test_energy; then
  warn_pwr="more than 100 watt-hours"
else
  warn_pwr="ok"
fi

if [ $warn_pwr = "ok" ]; then
  echo "Initial energy reading ($test_energy) is between 10 and 100 Wh, so power_divider is probably correct." | tee -a $logfile
else
  echo "WARNING: Energy reading ($test_energy) is $warn_pwr. Perhaps you need to adjust the power_divider?" | tee -a $logfile
  echo -n "Continue with the test anyway? [y/N] "
  read abort
  case $abort in [Yy]*) ;; *) do_exit 1;; esac;
fi

status=$(get_status)
[ $status = $discharging_string ] || { echo "battery status is '$status' -- not '$discharging_string'. We need to run on the battery."; do_exit 1; }
[ $USER = root ] || { echo "must run as root."; do_exit 1; }

# remove USB for external mouse before sleeping
modprobe -r usbhid uhci_hcd ehci_hcd

# save system time -- is this really necessary?
# hwclock --systohc

# get start values
date | tee -a $logfile
start_second=$(date +%s)
start_energy_reading=$(get_energy)
start_watt_hours=$(calcfunc $start_energy_reading / $power_divider)

# go to sleep
suspend_func

# get end values
end_second=$(date +%s)
end_energy_reading=$(get_energy)
end_watt_hours=$(calcfunc $end_energy_reading / $power_divider)
date | tee -a $logfile

# restore system time -- see above
# hwclock --hctosys

#restore usb
modprobe uhci_hcd ehci_hcd usbhid

secs_consumed=$(calcfunc $end_second-$start_second)
hours_consumed=$(calcfunc $secs_consumed/3600)
watt_hours_consumed=$(calcfunc $start_watt_hours-$end_watt_hours)
sleep_watts=$(calcfunc $watt_hours_consumed/$hours_consumed)

echo | tee -a $logfile
echo "start second: $start_second" | tee -a $logfile
echo "  end second: $end_second" | tee -a $logfile
echo "time consumed: $secs_consumed seconds" | tee -a $logfile
[ $secs_consumed -lt 1200 ] && echo "=== WARNING === sleep time was less than 20 minutes: results may not be reliable" | tee -a $logfile
echo | tee -a $logfile
echo "start energy: $start_watt_hours Wh" | tee -a $logfile
echo "  end energy: $end_watt_hours Wh" | tee -a $logfile
echo "energy consumed: $watt_hours_consumed Wh" | tee -a $logfile
echo | tee -a $logfile

echo "watts used while asleep = $sleep_watts" | tee -a $logfile
echo "(values above 1 are high)" | tee -a $logfile

if a_less_than_b $sleep_watts $warning_threshold; then
  echo "Results are good-- looks like your computer is sleeping soundly" | tee -a $logfile
else
  echo "Your computer is using a lot of power while sleeping." | tee -a $logfile
  echo "You may wish to refer to http://www.thinkwiki.org/wiki/How_to_reduce_power_consumption" | tee -a $logfile
fi

echo | tee -a $logfile

