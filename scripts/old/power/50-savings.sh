######################################################################################
# A script to aggressively toggle power management between high 
# performance and very low power consumption.
# For more information on each of these options, see http://www.lesswatts.org
# Last version script see http://axa-ru.blogspot.com/2012/01/thinkpad-x220-powersaving.html
################# Changes history ###################################################
VERSION=0.24

aUsb()
{
  #################################################
  ## USB Subsystem
  case "$1" in
    false)  #ac_power
      for i in /sys/bus/usb/devices/*/power/control
      do
        echo "on" > $i
      done
      ;;

    true)  #batt_power
      for i in /sys/bus/usb/devices/*/power/control
      do
        echo "auto" > $i
      done

      for i in /sys/bus/usb/devices/*/power/autosuspend
      do
        echo 1 > $i
      done

      echo 1 > /sys/module/usbcore/parameters/autosuspend
      ;;
  esac
}

aSata()
{
  case "$1" in
    false)  #ac_power
      # Set the SATA to max performance
      for i in /sys/class/scsi_host/host*/link_power_management_policy
      do
        echo max_performance > $i
      done
      ;;

    true)  #batt_power
      # Set SATA to minimum power
      for i in /sys/class/scsi_host/host*/link_power_management_policy
      do
        echo min_power > $i
      done
      ;;
  esac
}

aPci()
{
  case "$1" in
    false)  #ac_power
      for i in /sys/bus/pci/devices/*/power/control
      do
        echo on > $i
      done
      ;;

    true)  #batt_power
      for i in /sys/bus/pci/devices/*/power/control
      do
        echo auto > $i
      done
      ;;
  esac
}

aI2c()
{
  case "$1" in
    false)  #ac_power
      for i in /sys/bus/i2c/devices/i2c-*/power/control
      do
        echo on > $i
      done
      ;;

    true)  #batt_power
      for i in /sys/bus/i2c/devices/i2c-*/power/control
      do
        echo auto > $i
      done
      ;;
  esac
}

aHdd()
{
  case "$1" in
    false)  #ac_power
      # Set the drive to mostly stay awake.  Some may want to change -B 200
      # to -B 255 to avoid accumulating Load_Cycle_Counts
      # -S 240 => put in standby after 20 minutes idle
      # -B 200 => do not permit spindown
      # -M => not supported by my drive
      hdparm -B 200 -S 240 -M 254 /dev/sda

      # Remount ext3/4 filesystems so the journal commit only happens every 60
      # seconds.  By default this is 5 but, I prefer to reduce the disk
      # activity a bit.
      mount -o remount,commit=60,atime /
      ;;

    true)  #batt_power
      hdparm -B 1 -S 4 -M 128 /dev/sda
      mount -o remount,noatime,commit=600 /

      ;;
  esac
}

aSsd()
{

# add these commands in the /etc/rc.local
#  echo deadline > /sys/block/sda/queue/scheduler
#  echo 1 > /sys/block/sda/queue/iosched/fifo_batch
#  sysctl -w vm.swappiness=1            # Strongly discourage swapping
#  sysctl -w vm.vfs_cache_pressure=50   # Don't shrink the inode cache aggressively
  case "$1" in
    false)  #ac_power
      ;;

    true)  #batt_power
      ;;
  esac
}

aI915()
{
  case "$1" in
    false)  #ac_power
      echo 0 > /sys/module/i915/parameters/powersave
      ;;

    true)  #batt_power
      echo 1 > /sys/module/i915/parameters/powersave
      ;;
  esac
}

aWlan()
{
  # WiFi power savings.
  case "$1" in
    false)  #ac_power
      /sbin/iwconfig wlan0 power off txpower 14
      ;;

    true)  #batt_power
      /sbin/iwconfig wlan0 power on txpower 4
      ;;
  esac
}

aLan()
{
  case "$1" in
    false)  #ac_power
      # set the ethernet max speed.
      ethtool -s eth0 speed 1000 duplex full autoneg on wol d
      ;;
    true)  #batt_power
      # set the ethernet power savings.
      ethtool -s eth0 speed 10 duplex half autoneg off wol d
      ;;
  esac
}

aCpu()
{
  #################################################
  ## CPU
  ##

  case "$1" in
    false)  #ac_power
      for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      do
        echo performance > $i
      done

#      Enable All Core CPU
#      for i in /sys/devices/system/cpu/cpu*/online
#      do
#        echo 1 > $i
#      done

      # Shedule Multitreading
      echo 0 > /sys/devices/system/cpu/sched_mc_power_savings
      echo 0 > /sys/devices/system/cpu/sched_smt_power_savings
      ;;

    true)  #batt_power
      for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      do
        echo powersave > $i
      done

#      Disable cores not affected for power saving
#      for i in /sys/devices/system/cpu/cpu*/online
#      do
#        echo 0 > $i
#      done

      echo 1 > /sys/devices/system/cpu/sched_mc_power_savings
      echo 1 > /sys/devices/system/cpu/sched_smt_power_savings
      ;;
  esac
}

aSnd()
{
  case "$1" in
    false)  #ac_power
      echo 0 > /sys/module/snd_hda_intel/parameters/power_save
      ;;

    true)  #batt_power
      # Turn off sound card power savings
      # < 0.1 W
      echo 10 > /sys/module/snd_hda_intel/parameters/power_save
      ;;
  esac
}

aBt()
{
  case "$1" in
    false)  #ac_power
      # Enable the bluetooth driver
      rfkill unblock bluetooth
      ;;

    true)  #batt_power
      # Remove the bluetooth driver
      rfkill block bluetooth
      ;;
  esac
}

aWebcam()
{
  case "$1" in
    false)  #ac_power
      # Enable the webcam driver
      modprobe uvcvideo
      ;;

    true)  #batt_power
      # Remove the webcam driver
      modprobe -r uvcvideo
      ;;
  esac
}

aMemory()
{
  case "$1" in
    false)  #ac_power
      # Set kernel dirty page value back to default
      echo 10 > /proc/sys/vm/dirty_ratio
      echo 5 > /proc/sys/vm/dirty_background_ratio

      # Only wakeup every 60 seconds to see if we need to write dirty pages
      # By default this is every 5 seconds but, I prefer 60 to reduce disk
      # activity.
      echo 6000 > /proc/sys/vm/dirty_writeback_centisecs
      ;;

    true)  #batt_power
      # Reduce disk activity by waiting up to 10 minutes before doing writes
      echo 90 > /proc/sys/vm/dirty_ratio
      echo 1 > /proc/sys/vm/dirty_background_ratio
      echo 60000 > /proc/sys/vm/dirty_writeback_centisecs
      ;;
  esac
}

aMisc()
{
  case "$1" in
    false)  #ac_power
      # Turn off the laptop mode disk optimization
      echo 0 > /proc/sys/vm/laptop_mode
      echo tsc > /sys/devices/system/clocksource/clocksource0/current_clocksource

      # Powersave pci express
      echo performance > /sys/module/pcie_aspm/parameters/policy
      ;;

    true)  #batt_power
      # Set laptop disk write mode
      echo 5 > /proc/sys/vm/laptop_mode
      echo hpet > /sys/devices/system/clocksource/clocksource0/current_clocksource

      echo powersave > /sys/module/pcie_aspm/parameters/policy
      ;;
  esac
}

##########################################################

aCpu $1
aUsb $1
aI2c $1
aSata $1
aPci $1
if [ $(hdparm -i /dev/sda | grep Model | awk '{print substr($2,1,3)}') = "SSD" ]; 
  then 
    aSsd $1
  else
    aHdd $1
fi
aI915 $1
aWlan $1
aLan $1
aSnd $1
aBt $1
aWebcam $1
aMemory $1
aMisc $1

