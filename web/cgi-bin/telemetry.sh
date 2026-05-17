#!/system/bin/sh
echo "HTTP/1.1 200 OK"
echo "Content-Type: application/json"
echo ""

# Helpers
get_cpu_temp() {
    T=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    [ -z "$T" ] && echo 0 && return
    if [ "$T" -gt 1000 ]; then T=$((T / 1000)); fi
    echo "$T"
}

get_gpu_temp() {
    # Typical path for MTK or Adreno
    T=$(cat /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
    [ -z "$T" ] && echo 0 && return
    if [ "$T" -gt 1000 ]; then T=$((T / 1000)); fi
    echo "$T"
}

get_cpu_freq() {
    F=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
    [ -z "$F" ] && echo 0 && return
    echo $((F / 1000))
}

echo "{\"cpu_temp\": $(get_cpu_temp), \"gpu_temp\": $(get_gpu_temp), \"cpu_freq\": $(get_cpu_freq)}"
