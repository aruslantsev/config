# hciconfig hci0 down # rfkill rulezzz :)
# rmmod hci_usb
ethtool -s eth0 wol d
ethtool -s eth0 autoneg off speed 10
echo min_power > /sys/class/scsi_host/host0/link_power_management_policy
echo min_power > /sys/class/scsi_host/host1/link_power_management_policy
echo min_power > /sys/class/scsi_host/host2/link_power_management_policy
echo min_power > /sys/class/scsi_host/host3/link_power_management_policy
echo min_power > /sys/class/scsi_host/host4/link_power_management_policy
echo min_power > /sys/class/scsi_host/host5/link_power_management_policy
echo 5 > /sys/module/usbcore/parameters/autosuspend
echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller
echo powersave > /sys/module/pcie_aspm/parameters/policy
modprobe -r uvcvideo
# echo 1 > /sys/devices/system/cpu/sched_mc_power_savings # managed by laptop-mode
# echo 1 > /sys/devices/system/cpu/sched_smt_power_savings # managed by laptop-mode
# iwconfig wlan0 power timeout 500ms # unsupported
# echo 6000 > /proc/sys/vm/dirty_writeback_centisecs # not tested
