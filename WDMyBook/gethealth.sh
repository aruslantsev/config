if [ ! -f $1 ]
    then echo "date,uptime,T(hda),realloc(hda),pending(hda),startstop(hda),loads(hda),T(hdb),realloc(hdb),pending(hdb),startstop(hdb),loads(hdb),la1min,la5min,la15min,memtotal,memused,memfree,memshared,membuffers,memcached,swaptotal,swapused,swapfree,users,rootused,rootinodes,dataused,datainodes" > $1
fi

echo $(
    date +"%Y-%m-%d %H:%M:%S"
    echo ,
    awk '{print int($1)}' /proc/uptime
    echo ,
    smartctl -a /dev/sda | grep Temperature | awk '{print $10}'
    echo ,
    smartctl -a /dev/sda | grep Reallocated_Sector | awk '{print $10}'
    echo ,
    smartctl -a /dev/sda | grep Pending_Sector | awk '{print $10}'
    echo ,
    smartctl -a /dev/sda | grep Start_Stop | awk '{print $10}'
    echo ,
    smartctl -a /dev/sda | grep Load_Cycle | awk '{print $10}'
    echo ,
    smartctl -a /dev/sdb | grep Temperature | awk '{print $10}'
    echo ,
    smartctl -a /dev/sdb | grep Reallocated_Sector | awk '{print $10}'
    echo ,
    smartctl -a /dev/sdb | grep Pending_Sector | awk '{print $10}'
    echo ,
    smartctl -a /dev/sdb | grep Start_Stop | awk '{print $10}'
    echo ,
    smartctl -a /dev/sdb | grep Load_Cycle | awk '{print $10}'
    echo ,
    uptime | awk '{print $10 $11 $12}'
    echo ,
    free -m | grep Mem | awk '{print $2","$3","$4","$5","$6","$7}'
    echo ,
    free -m | grep Swap | awk '{print $2","$3","$4}'
    echo ,
    who | wc -l
    echo ,
    df -h | grep /dev/md1 | awk '{print $5}'
    echo ,
    df -i | grep /dev/md1 | awk '{print $5}'
    echo ,
    df -h | grep /dev/md3 | awk '{print $5}'
    echo ,
    df -i | grep /dev/md3 | awk '{print $5}'
) >> $1
