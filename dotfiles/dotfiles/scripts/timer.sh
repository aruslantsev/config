function convert_time {
	local t=$1

	local d=$((t/60/60/24))
	local h=$((t/60/60%24))
	local m=$((t/60%60))
	local s=$((t%60))

	timestr=""
	if [[ $d > 0 ]]; then
		timestr="${timestr}${d}d"
	fi
	if [[ $h > 0 ]] || [[ $d > 0 ]]; then
		timestr="${timestr}${h}h"
	fi
	if [[ $m > 0 ]] || [[ $h > 0 ]] || [[ $d > 0 ]]; then
		timestr="${timestr}${m}m"
	fi
	timestr="${timestr}${s}s"
	echo "${timestr}"
}

function timer_start {
	timer=${timer:-$SECONDS}
}

function timer_stop {
	timer_show=$(($SECONDS - $timer))
	unset timer
}

function get_exectime {
	convert_time timer_show
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=timer_stop
