#!/bin/bash

# tp-fancontrol 0.3.02 (http://thinkwiki.org/wiki/ACPI_fan_control_script)
# Provided under the GNU General Public License version 2 or later or
# the GNU Free Documentation License version 1.2 or later, at your option.
# See http://www.gnu.org/copyleft/gpl.html for the Warranty Disclaimer.

# This script dynamically controls fan speed on some ThinkPad models
# according to user-defined temperature thresholds.  It implements its
# own decision algorithm, overriding the ThinkPad embedded
# controller. It also implements a workaround for the fan noise pulse
# experienced every few seconds on some ThinkPads.
#
# Run 'tp-fancontrol --help' for options.
#
# For optimal fan behavior during suspend and resume, invoke 
# "tp-fancontrol -u" during the suspend process.
# 
# WARNING: This script relies on undocumented hardware features and
# overrides nominal hardware behavior. It may thus cause arbitrary
# damage to your laptop or data. Watch your temperatures!
#
# WARNING: The list of temperature ranges used below is much more liberal
# than the rules used by the embedded controller firmware, and is
# derived mostly from anecdotal evidence, hunches and wishful thinking.
# It is also model-specific (see http://thinkwiki.org/wiki/Thermal_sensors).

# Temperature ranges, per sensor:
# (min temperature: when to step up from 0-th fan level,
#  max temperature: when to step up to maximum fan level)
THRESHOLDS=( #  Sensor     ThinkPad model
             #             R51     T41/2  Z60t   T43-26xx
# min  max   #  ---------- ------- -----  -----  ---------------------------
  50   70    #  EC 0x78    CPU     CPU    ?      CPU
  47   60    #  EC 0x79    miniPCI ?      ?      Between CPU and PCMCIA slot
  43   55    #  EC 0x7A    HDD     ?      ?      PCMCIA slot
  49   68    #  EC 0x7B    GPU     GPU    ?      GPU
  40   50    #  EC 0x7C    BAT     BAT    BAT    Sys BAT (front left of battery)
  40   50    #  EC 0x7D    n/a     n/a    n/a    UltraBay BAT
  37   47    #  EC 0x7E    BAT     BAT    BAT    Sys BAT (rear right of battery)
  37   47    #  EC 0x7F    n/a     n/a    n/a    UltraBay BAT

  45   60    #  EC 0xC0    ?       n/a    ?      Between northbridge and DRAM
  48   62    #  EC 0xC1    ?       n/a    ?      Southbridge (under miniPCI)
  50   65    #  EC 0xC2    ?       n/a    ?      Power circuitry (under CDC)

  47   58    #  HDD        ->      ->     ->     Hard disk internal sensor
  47   60    #  HDAPS      ->      ->     ->     HDAPS readout (same as EC 0x79)
)


LEVELS=(    0      2      4      7)  # Fan speed levels
ANTIPULSE=( 0      1      1      0)  # Prevent fan pulsing noise at this level
                                     # (reduces frequency of fan RPM updates)

OFF_THRESH_DELTA=3 # when gets this much cooler than 'min' above, may turn off fan
MIN_THRESH_SHIFT=0 # increase min thresholds by this much
MAX_THRESH_SHIFT=0 # increase max thresholds by this much
MIN_WAIT=180 # minimum time (seconds) to spend in a given level before stepping down

IBM_ACPI=/proc/acpi/ibm
HDAPS_TEMP=/sys/bus/platform/drivers/hdaps/hdaps/temp1
PID_FILE=/var/run/tp-fancontrol.pid
LOGGER=/usr/bin/logger
INTERVAL=3        # sample+refresh interval
SETTLE_TIME=6     # wait this many seconds long before applying anti-pulsing
RESETTLE_TIME=600 # briefly disable anti-pulsing at every N seconds
SUSPEND_TIME=5    # seconds to sleep when receiving SIGUSR1
DISK_POLL_PERIOD=15 # poll period in seconds for disk sensors (it changes slowly and is expensive to read)
HITACHI_MODELS="^(HTS4212..H9AT00|HTS726060M9AT00|HTS5410..G9AT00|IC25[NT]0..ATCS0[45]|HTE541040G9AT00|HTS5416..J9(AT|SA)00)"
SEP=','           # Separator char for display

WATCHDOG_DELAY=$(( 3 * INTERVAL ))
HAVE_WATCHDOG=`grep -q watchdog $IBM_ACPI/fan && echo true || echo false`
HAVE_LEVELCMD=`grep -q disengaged $IBM_ACPI/fan && echo true || echo false`

QUIET=false
DRY_RUN=false
DAEMONIZE=false
AM_DAEMON=false
KILL_DAEMON=false
SUSPEND_DAEMON=false
SYSLOG=false
DISK_POLL_TIME=-$DISK_POLL_PERIOD

usage() {
    echo "
Usage: $0 [OPTION]...

Available options:
   -s N   Shift up the min temperature thresholds by N degrees
          (positive for quieter, negative for cooler).
          Max temperature thresholds are not affected.
   -S N   Shift up the max temperature thresholds by N degrees
          (positive for quieter, negative for cooler). DANGEROUS.
   -t     Test mode
   -q     Quiet mode
   -d     Daemon mode, go into background (implies -q)
   -l     Log to syslog
   -k     Kill already-running daemon
   -u     Tell already-running daemon that the system is being suspended
   -p     Pid file location for daemon mode, default: $PID_FILE
"
    exit 1;
}

while getopts 's:S:qtdlp:kuh' OPT; do
    case "$OPT" in
        s) # shift thresholds
            MIN_THRESH_SHIFT="$OPTARG"
            ;;
        S) # shift thresholds
            MAX_THRESH_SHIFT="$OPTARG"
            ;;
        t) # test mode
            DRY_RUN=true
            ;;
        q) # quiet mode
            QUIET=true
            ;;
        d) # go into background and daemonize
            DAEMONIZE=true
            ;;
        l) # log to syslog
            SYSLOG=true
            ;;
        p) # different pidfile
            PID_FILE="$OPTARG"
            ;;
        k) # kill daemon
            KILL_DAEMON=true
            ;;
        u) # suspend daemon
            SUSPEND_DAEMON=true
            ;;
        h) # short help
            usage
            ;;
        \?) # error
            usage
            ;;
    esac
done
[ $OPTIND -gt $# ] || usage  # no non-option args

# no logger found, no syslog capabilities
$SYSLOG && [ ! -x $LOGGER ] && SYSLOG=false || :

if $DRY_RUN; then
    echo "$0: Dry run, will not change fan state."
    QUIET=false
    DAEMONIZE=false
fi

# Read the temperature sensor on new Hitachi drivers without spinning up the
# disk or unloading its head (this cannot be done using standard SMART).
# Works only with drivers/ide or new libata. Equivalent to hdparm -H in >=6.7.
read_hitachi_temp() { perl - "$@" <<'EOPERL'    # do it in Perl
    #!/usr/bin/perl
    $dev="$ARGV[0]" or die "No device given.\n";
    $HDIO_DRIVE_CMD=0x031f;
    $args=pack("cccc",0xf0,0,0x01,0);   # Sense Condition command
    open(DEV,"<",$dev) or die "open(\"$dev\"): $!\n";
    if (ioctl(DEV,$HDIO_DRIVE_CMD,$args)) {
       $nsect=(unpack("cccc",$args))[2];
       if ($nsect==0 || $nsect==0xff) {
           die "Temperature over/underflow.\n";
       } elsif ($nsect==0x01) {  # Linux<=2.6.18 doesn't return ATA registers
           die "Old Linux kernel, readout not supported.\n";
       } else {
           printf "%d\n", $nsect/2-20;
       }
    } else {
        die "ioctl(\"$dev\",HDIO_DRIVE_CMD,SENSE_CONDITION): $!\n"
    }
EOPERL
}

update_disk_temp() {
    if (( SECONDS >= DISK_POLL_TIME + DISK_POLL_PERIOD )); then
        LAST_DISK_TEMP="-128"
        for DEV in {sda,hda}; do
            if [[ -b "/dev/$DEV" ]]; then
                local MODEL=`cat /sys/block/$DEV/device/model`
                if [[ "$MODEL" =~ "$HITACHI_MODELS" ]]; then
                    if HTEMP=`read_hitachi_temp "/dev/$DEV" 2>/dev/null`; then
                        LAST_DISK_TEMP="$HTEMP"
                        break
                    fi
                fi
            fi
        done
        DISK_POLL_TIME=$SECONDS
    fi
}

thermometer() { # output list of temperatures
    # 8 basic temperatures from ibm-acpi:
    [[ -r $IBM_ACPI/thermal ]] || { echo "$0: Cannot read $IBM_ACPI/thermal" 2>&1 ; exit 1; }
    read THERMAL < $IBM_ACPI/thermal
    read X Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Z1 Z2 Z3 JNK < <(echo "$THERMAL") 
    [[ "$X" == "temperatures:" ]] || { echo "$0: Bad readout: \"$THERMAL\"" >&2;  exit 1; }
    echo -n "$Y1 $Y2 $Y3 $Y4 $Y5 $Y6 $Y7 $Y8 ";
    # 3 extra temperatures from ibm_acpi:
    if [[ -n "$Z1" && -n "$Z2" && -n "$Z3" ]]; then 
        # ibm_acpi provided extra sensors from at EC offsets 0xC0 to 0xC2?
        echo -n "$SEP $Z1 $Z2 $Z3 "
    else 
        [ -r $IBM_ACPI/ecdump ] || { echo "$0: Cannot read $IBM_ACPI/ecdump" 2>&1; exit 1; }
        perl -e 'm/^EC 0xc0: .(..) .(..) .(..) / and print hex($1)." ".hex($2)." ".hex($3)." " and exit 0 while <>; exit 1' < $IBM_ACPI/ecdump
    fi
    # 1 Disk drive temperatures:
    echo -n "$SEP $LAST_DISK_TEMP "
    # 1 HDAPS temperature (optional):
    if [ -r $HDAPS_TEMP ]; then
        Y="`cat $HDAPS_TEMP`"
        (( "$Y" > 100 )) || echo -n "$Y "  # the HDAPS readouts are nonsensical right after resume
    fi
    return 0
}

speedometer() { # output fan speed RPM
    sed -n 's/^speed:[ \t]*//p' $IBM_ACPI/fan
}

setlevel() { # set fan speed level
    local LEVEL=$1
    if ! $DRY_RUN; then
        if $HAVE_LEVELCMD; then
        	echo "level $LEVEL" > $IBM_ACPI/fan
	else
		case "$LEVEL" in
		(auto)        LEVEL=0x80 ;;
		(disengaged)  LEVEL=0x40 ;;
		esac
        	echo 0x2F $LEVEL > $IBM_ACPI/ecdump
	fi
    fi
}

getlevel() { # get fan speed level
    perl -e 'm/^EC 0x20: .* .(..)$/ and print $1 and exit 0 while <>; exit 1' < $IBM_ACPI/ecdump
}

log() {
	$QUIET || echo "> $*"
	! $SYSLOG || $LOGGER -t "`basename $0`[$$]" "$*"
}

cleanup() { # clean up after work
    $AM_DAEMON && rm -f "$PID_FILE" 2> /dev/null
    log "Shutting down, switching to automatic fan control"
    if ! $DRY_RUN; then
        if $HAVE_LEVELCMD; then
            echo enable > $IBM_ACPI/fan
        else
            echo 0x2F 0x80 > $IBM_ACPI/ecdump
        fi
        if $HAVE_WATCHDOG; then
            echo watchdog 0 > $IBM_ACPI/fan  # disable watchdog
        fi
    fi
}

floor_div() {
    echo $(( (($1)+1000*($2))/($2) - 1000 ))
}

set_priority() {
    ! $DRY_RUN && renice -10 -p $$
}

init_state() {
    IDX=0
    NEW_IDX=0
    START_TIME=0
    MAX_IDX=$(( ${#LEVELS[@]} - 1 ))
    SETTLE_LEFT=0
    RESETTLE_LEFT=0
    FIRST=true
    RESTART=false
}

control_fan() {
    # Enable the fan in default mode if anything goes wrong:
    set -e -E -u
    trap "cleanup; exit 2" HUP INT ABRT QUIT SEGV TERM
    trap "cleanup" EXIT
    trap "log 'Got SIGUSR1'; setlevel 0; RESTART=true; sleep $SUSPEND_TIME" USR1
    if ! $DRY_RUN && $HAVE_WATCHDOG; then
        log "Activating watchdog with delay $WATCHDOG_DELAY sec"
        echo "watchdog $WATCHDOG_DELAY" > $IBM_ACPI/fan
    fi

    init_state
    log "Starting dynamic fan control"

    # Control loop:
    while true; do
        # Get readouts
        update_disk_temp  # don't do this in a subshell, it's stateful
        TEMPS=`thermometer`
        $QUIET || SPEED=`speedometer`
        $QUIET || ECLEVEL=`getlevel`
        NOW=`date +%s`
        if echo "$TEMPS" | grep -q "[^ 0-9$SEP\n-]"; then
            echo "Invalid character in temperatures: $TEMPS" >&2; exit 1;
        fi

        # Calculate new level index by placing temperatures into regions of "Z" values:
        # Z >= 2*I means "must be at index I or higher"
        # Z  = 2*I+1 is hysteresis: "don't step down if currently at I+1"
        # The set of temperatures for each Z value are as follows, denoting d=(MAX-MIN)/(2*(MAX_IDX-1)) :
        #   Z=0:         {-infty..MIN-OFF_THRESH_DELTA)     Z=1:   {MIN-OFF_THRESH_DELTA..MIN}
        #   Z=2:         {MIN..MIN+d}         Z=3:   {MIN+d..MIN+2d}
        #   Z=4:         {MIN+2d..MIN+3d}     Z=5:   {MIN+3d..MIN+4d}   ...
        #   Z=2*MAX_IDX: {MAX..infty}

        # Enforce minimum time in this level before stepping down:
        MAX_Z=$(( IDX>0 ? ( NOW>START_TIME+MIN_WAIT ? 2*(IDX-1) : 2*IDX ) : 0 ))

        # Go over all sensors and compute the Z value; compute the maximum Z and a pretty-printed string:
        SENSOR=0
        Z_STR="$MAX_Z+"
        TEMP_STR="";
        for TEMP in $TEMPS; do
            if [[ "$TEMP" == "$SEP" ]]; then   # ignore this (a separator for visual aid)
                Z_STR="${Z_STR}$SEP"
                TEMP_STR="${TEMP_STR}$SEP "
                continue
            fi
            [ $((2*SENSOR+2)) -le ${#THRESHOLDS[@]} ] ||
                { echo "Too many sensors, not enough values in THRESHOLDS" 2>&1; exit 1; }
            if [[ $TEMP == -128 || $TEMP == 128 ]]; then
                Z='_'; TEMP='_' # inactive sensor
            else
                MIN=$((THRESHOLDS[SENSOR*2] + MIN_THRESH_SHIFT))
                MAX=$((THRESHOLDS[SENSOR*2+1] + MAX_THRESH_SHIFT ))
                [[ $MAX -le $MIN ]] && \
                    { echo 'Reversed temperature thresholds (shifted too much?)' 2>&1; exit 1; }
                if (( TEMP < MIN - OFF_THRESH_DELTA )); then
                    Z=0
                else  # compute Z value for this sensor (see above):
                    Z=$(( `floor_div $(( 2*(TEMP-MIN)*(MAX_IDX-1) )) $((MAX-MIN))` + 2 ))
                    [ $Z -ge 1 ] || Z=1
                    [ $Z -le $((2*MAX_IDX)) ] || Z=$((2*MAX_IDX))
                fi
                [ $MAX_Z -gt $Z ] || MAX_Z=$Z
            fi
            Z_STR="${Z_STR}${Z}"
            TEMP_STR="${TEMP_STR}${TEMP} "
            (( ++SENSOR ))
        done
        [ $SENSOR -gt 0 ] || { echo "No temperatures read" >&2; exit 1; }

        HYS=$(( (MAX_Z == 2*IDX-1) && ++MAX_Z )) # hysteresis
        NEW_IDX=$(( MAX_Z/2 ))

        # Interrupted by a signal?
        if $RESTART; then
            init_state
            log "Resetting state"
            continue
        fi

        # Transition
        $FIRST && OLDLEVEL='?' || OLDLEVEL=${LEVELS[$IDX]}
        NEWLEVEL=${LEVELS[$NEW_IDX]}
        $QUIET || echo "L=$OLDLEVEL->$NEWLEVEL EC=$ECLEVEL RPM=`printf %4s $SPEED` T=($TEMP_STR) Z=$Z_STR"
        if [ "$OLDLEVEL" != "$NEWLEVEL" ]; then
            START_TIME=$NOW
            log "Changing fan level: $OLDLEVEL->$NEWLEVEL  (temps: $TEMP_STR)"
        fi

        setlevel $NEWLEVEL

        sleep $INTERVAL

        # If needed, apply anti-pulsing hack after a settle-down period (and occasionally re-settle):
        if [ ${ANTIPULSE[${NEW_IDX}]} == 1 ]; then 
            if [ $NEWLEVEL != $OLDLEVEL -o $RESETTLE_LEFT -le 0 ]; then # start settling?
                SETTLE_LEFT=$SETTLE_TIME
                RESETTLE_LEFT=$RESETTLE_TIME
            fi
            if [ $SETTLE_LEFT -ge 0 ]; then
                SETTLE_LEFT=$((SETTLE_LEFT-INTERVAL))
            else
                setlevel disengaged # disengage briefly to fool embedded controller
                sleep 0.5
                RESETTLE_LEFT=$((RESETTLE_LEFT-INTERVAL))
            fi
        fi

        IDX=$NEW_IDX
        FIRST=false
    done
}

if $KILL_DAEMON || $SUSPEND_DAEMON; then 
    if [ -f "$PID_FILE" ]; then
	set -e
	DPID="`cat \"$PID_FILE\"`" 
	if $KILL_DAEMON; then
        	kill "$DPID"
		rm "$PID_FILE"
		$QUIET || echo "Killed process $DPID"
	else # SUSPEND_DAEMON
		kill -USR1 "$DPID"
		$QUIET || echo "Sent SIGUSR1 to $DPID"
	fi
    else
        $QUIET || echo "Daemon not running."
        exit 1
    fi
elif $DAEMONIZE ; then
    if [ -e "$PID_FILE" ]; then
        echo "$0: File $PID_FILE already exists, refusing to run."
        exit 1
    else
        set_priority
        AM_DAEMON=true QUIET=true control_fan 0<&- 1>&- 2>&- &
        echo $! > "$PID_FILE"
        exit 0
    fi
else
    [ -e "$PID_FILE" ] && echo "WARNING: daemon already running"
    set_priority
    control_fan
fi