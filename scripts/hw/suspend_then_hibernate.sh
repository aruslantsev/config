#!/usr/bin/env bash
# Toggle hibernation after a defined period of sleep

# Define the time until hibernation in seconds
autohibernate=10800

# Suspending.  Record current time and set a wake up timer.
suspend_time=$(date +%s)
rtcwake -m mem -s $autohibernate

# Wakeup.
sleep 1
current_time=$(date +%s)
# Did we wake up due to the rtc timer above?
if [ $(($current_time - $suspend_time)) -ge $autohibernate ]
then
	# Then hibernate
	echo Suspending to disk
	echo disk > /sys/power/state
else
	# Otherwise cancel the rtc timer and wake up normally.
	echo Wake up
	rtcwake -m no -s 1
fi
