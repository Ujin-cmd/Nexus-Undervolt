#!/system/bin/sh
echo "HTTP/1.1 200 OK"
echo "Content-Type: application/json"
echo "Access-Control-Allow-Origin: *"
echo ""

# Function to read hardware nodes safely
get_val() {
    val=$(cat "$1" 2>/dev/null)
    [ -z "$val" ] && echo "N/A" || echo "$val"
}

SOC_MODEL=$(getprop ro.soc.model)
SOC_MANUF=$(getprop ro.soc.manufacturer)
SOC_PLAT="$(getprop ro.board.platform)"
[ -z "$SOC_PLAT" ] && SOC_PLAT="$(getprop ro.hardware)"

if [ -n "$SOC_MANUF" ] && [ -n "$SOC_MODEL" ]; then
    SOC="$SOC_MANUF $SOC_MODEL"
    [ -n "$SOC_PLAT" ] && [ "$SOC_PLAT" != "$SOC_MODEL" ] && SOC="$SOC ($SOC_PLAT)"
else
    SOC="$SOC_PLAT"
fi

HW=$(grep "Hardware" /proc/cpuinfo | cut -d ":" -f2 | xargs)
[ -n "$HW" ] && SOC="$SOC [$HW]"

[ -z "$SOC" ] && SOC="Unknown Processing Unit"
SOC=$(echo "$SOC" | sed 's/mt/MT/g')

V_B=$(get_val "/proc/eem/EEM_DET_B/eem_offset")
V_L=$(get_val "/proc/eem/EEM_DET_L/eem_offset")
V_GPU=$(get_val "/proc/eem/EEM_DET_GPU/eem_offset")

GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
[ -z "$GOV" ] && GOV="unknown"

# Default thermal threshold display (from config)
THERMAL="70"
if [ -f "/data/local/tmp/underover.conf" ]; then
    . "/data/local/tmp/underover.conf"
    [ -n "$THERM_CONF" ] && THERMAL="$THERM_CONF"
fi

# Dynamic EEM Node Scanner
EEM_NODES="["
if [ -d "/proc/eem" ]; then
    first=1
    for node in /proc/eem/*; do
        if [ -d "$node" ] && [ -f "$node/eem_offset" ]; then
            domain=$(basename "$node")
            if [ $first -eq 1 ]; then
                EEM_NODES="${EEM_NODES}\"${domain}\""
                first=0
            else
                EEM_NODES="${EEM_NODES}, \"${domain}\""
            fi
        fi
    done
fi
EEM_NODES="${EEM_NODES}]"

SUPPORTED="MediaTek Helio G90T (Custom EEM) and EEM-compatible Kernels."

cat <<EOF
{
  "soc": "$SOC",
  "supported_cpus": "$SUPPORTED",
  "actual_cpu_uv": "$V_B",
  "actual_l_uv": "$V_L",
  "actual_gpu_uv": "$V_GPU",
  "governor": "$GOV",
  "thermal_limit": "$THERMAL",
  "detected_eem_nodes": $EEM_NODES
}
EOF
