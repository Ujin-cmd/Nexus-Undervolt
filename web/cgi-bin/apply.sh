#!/system/bin/sh

read -n $CONTENT_LENGTH POST_DATA
# Example POST_DATA: {"cpu":"-20","gpu":"-5","c4":"0","c5":"1","c6":"1","c7":"1"}

extract() {
    echo "$POST_DATA" | grep -o "\"$1\":\"[^\"]*" | cut -d'"' -f4
}

CPU=$(extract "cpu")
GPU=$(extract "gpu")
GOV=$(extract "gov")
THERM=$(extract "thermal")

# Default fallbacks
[ -z "$CPU" ] && CPU="0"
[ -z "$GPU" ] && GPU="0"
[ -z "$GOV" ] && GOV="schedutil"
[ -z "$THERM" ] && THERM="65"

CONF="/data/local/tmp/underover.conf"
echo "CPU=\"$CPU\"" > "$CONF"
echo "GPU=\"$GPU\"" >> "$CONF"
echo "GOV_CONF=\"$GOV\"" >> "$CONF"
echo "THERM_CONF=\"$THERM\"" >> "$CONF"

# Immediately apply the new config to hardware
sh /data/adb/modules/Undervolting/system/bin/underover_apply > /data/local/tmp/underover_log.txt 2>&1

echo "HTTP/1.1 200 OK"
echo "Content-Type: application/json"
echo ""
echo "{\"status\":\"Settings applied successfully to kernel layer.\"}"
