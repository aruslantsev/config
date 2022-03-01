#!/bin/sh

. /usr/lib/tuned/functions

start() {
    [ "$USB_AUTOSUSPEND" = 1 ] && enable_usb_autosuspend
    enable_wifi_powersave
    cpupower -c 0,1,2,3 frequency-set -u 1200000
    hdparm -B 20 -S 240 /dev/sda
    hdparm -B 20 -S 240 /dev/sdb
    hdparm -B 20 -S 240 /dev/sdc
    hdparm -B 20 -S 240 /dev/sdd
    hdparm -B 255 -S 0 /dev/sde
    return 0
}

stop() {
    [ "$USB_AUTOSUSPEND" = 1 ] && disable_usb_autosuspend
    disable_wifi_powersave
    cpupower -c 0,1,2,3 frequency-set -u 4800000
    hdparm -B 255 -S 0 /dev/sda
    hdparm -B 255 -S 0 /dev/sdb
    hdparm -B 255 -S 0 /dev/sdc
    hdparm -B 255 -S 0 /dev/sdd
    hdparm -B 255 -S 0 /dev/sde
    return 0
}

process $@
