total_cpus=$(grep processor /proc/cpuinfo | wc -l)
total_mem_mb=$(free -m | awk 'NR==2{printf $2 }')

function loadavg {
	loadavg_1m=$(cut -d\  -f1 /proc/loadavg)
	loadavg_5m=$(cut -d\  -f2 /proc/loadavg)
	loadavg_15m=$(cut -d\  -f3 /proc/loadavg)
	echo "LoadAvg: ${loadavg_1m}, ${loadavg_5m}, ${loadavg_15m}"
}

function get_mem {
	# mem=$(free -m | awk 'NR==2{printf "Mem: %.0f/%.0fGB (%.0f%%)\n", $3/1024,$2/1024,$3*100/$2 }')
	# swap=$(free -m | awk 'NR==3{printf "Swp: %.0f/%.0fGB (%.0f%%)\n", $3/1024,$2/1024,$3*100/$2 }')
	# echo "${mem}, ${swap}"
	if [ ${total_mem_mb} -ge 8192 ]; then
		mem=$(free -g | awk 'NR==2{printf "Mem: %.0f/%.0fGB\n", $3,$2 }')
		swap=$(free -g | awk 'NR==3{printf "Swap: %.0f/%.0fGB\n", $3,$2 }')
		echo "${mem}, ${swap}"
	else
		mem=$(free -m | awk 'NR==2{printf "Mem: %.0f/%.0fMB\n", $3,$2 }')
	        swap=$(free -m | awk 'NR==3{printf "Swap: %.0f/%.0fMB\n", $3,$2 }')
		echo "${mem}, ${swap}"
	fi
}

function get_system_load {
	echo "$(loadavg). $(get_mem)"
}
