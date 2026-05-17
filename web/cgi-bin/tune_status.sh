#!/system/bin/sh
echo "HTTP/1.1 200 OK"
echo "Content-Type: application/json"
echo ""

LOG="/data/local/tmp/autotune.log"
if [ ! -f "$LOG" ]; then
    echo "{\"status\":\"idle\",\"msg\":\"No tuning process active.\",\"uv\":0}"
    exit 0
fi

STATUS=$(grep "^status=" "$LOG" | tail -n 1 | cut -d= -f2)
MSG=$(grep "^msg=" "$LOG" | tail -n 1 | cut -d= -f2-)
UV=$(grep "^uv=" "$LOG" | tail -n 1 | cut -d= -f2)

[ -z "$STATUS" ] && STATUS="idle"
[ -z "$MSG" ] && MSG="Running..."
[ -z "$UV" ] && UV="0"

# Basic escape for quotes
MSG_ESC=$(echo "$MSG" | sed 's/"/\\"/g')

echo "{\"status\":\"$STATUS\",\"msg\":\"$MSG_ESC\",\"uv\":$UV}"
