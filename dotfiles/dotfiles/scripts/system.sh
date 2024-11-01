if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # total_cpus=$(grep processor /proc/cpuinfo | wc -l)
  total_mem_mb=$(free -m | awk 'NR==2{printf $2 }')

  function loadavg {
    awk '{printf "LoadAvg: %s, %s, %s", $1, $2, $3}' /proc/loadavg
  }
  function get_mem {
    # mem=$(free -m | awk 'NR==2{printf "Mem: %.0f/%.0fGB (%.0f%%)\n", $3/1024,$2/1024,$3*100/$2 }')
    # swap=$(free -m | awk 'NR==3{printf "Swp: %.0f/%.0fGB (%.0f%%)\n", $3/1024,$2/1024,$3*100/$2 }')
    if [ ${total_mem_mb} -ge 8192 ]; then
      mem=$(free -g | awk 'NR==2{printf "Mem: %.0f/%.0fGB\n", $3,$2 }')
      swap=$(free -g | awk 'NR==3{printf "Swap: %.0f/%.0fGB\n", $3,$2 }')
    else
      mem=$(free -m | awk 'NR==2{printf "Mem: %.0f/%.0fMB\n", $3,$2 }')
      swap=$(free -m | awk 'NR==3{printf "Swap: %.0f/%.0fMB\n", $3,$2 }')
    fi
    echo "${mem}, ${swap}"
  }
  function get_system_load {
    echo "$(loadavg). $(get_mem)"
  }
elif [[ "$OSTYPE" == "darwin"* ]]; then
  function loadavg {
    sysctl -n vm.loadavg | awk '{printf "LoadAvg: %s, %s, %s", $2, $3, $4}'
  }
  function get_mem {
    total_mem=$(sysctl -n hw.memsize)
    page_size=$(vm_stat | head -n 1 | grep --color=never -o -E "[0-9]+")
    free_count=$(vm_stat | grep --color=never "Pages free" | grep --color=never -o -E "[0-9]+")
    speculative_count=$(vm_stat | grep --color=never "Pages speculative" | grep --color=never -o -E "[0-9]+")
    inactive_count=$(vm_stat | grep --color=never "Pages inactive" | grep --color=never -o -E "[0-9]+")
    purgeable_count=$(vm_stat | grep --color=never "Pages purgeable" | grep --color=never -o -E "[0-9]+")
    used_mem=$((${total_mem}-(${free_count}+${speculative_count}+${purgeable_count}+${inactive_count})*${page_size}))
    total_mem=$((${total_mem}/1024/1024))
    used_mem=$((${used_mem}/1024/1024))
    swap_total=$(sysctl -n vm.swapusage | awk '{print $3}')
    swap_used=$(sysctl -n vm.swapusage | awk '{print $6}')
    unit=${swap_total: -1}
    swap_total=${swap_total%.*}
    swap_used=${swap_used%.*}
    if [ $unit = "G" ]; then
      swap_total=$((${swap_total}*1024))
      swap_used=$((${swap_used}*1024))
    fi
    if [ ${total_mem} -ge 8192 ]; then
      total_mem=$((${total_mem}/1024))
      used_mem=$((${used_mem}/1024))
      mem="Mem: ${used_mem}/${total_mem}GB"
      swap_total=$((${swap_total}/1024))
      swap_used=$((${swap_used}/1024))
      swap="Swap: ${swap_used}/${swap_total}GB"
    else
      mem="Mem: ${used_mem}/${total_mem}MB"
      swap="Swap: ${swap_used}/${swap_total}MB"
    fi
    echo "${mem}, ${swap}"
  }
  function get_system_load {
    echo "$(loadavg). $(get_mem)"
  }
else
  function get_system_load {
      echo -n
    }
fi
