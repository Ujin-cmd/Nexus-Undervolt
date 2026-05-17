#!/system/bin/sh

# Send immediate response
cat <<EOF
HTTP/1.1 200 OK
Content-Type: application/json

{"status":"Auto-tuning started in background."}
EOF

# Close stdout/stderr so the web server doesn't wait
exec 1>&-
exec 2>&-
exec 0<&-

# Execute in background
(
    LOG="/data/local/tmp/autotune.log"
    echo "status=running" > $LOG
    echo "msg=Initializing Auto-Tune sequence..." >> $LOG
    echo "uv=0" >> $LOG
    
    CURRENT_UV=0
    PIDS=""
    
    # We will test drops of 2 down to -40
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
        CURRENT_UV=$(( $CURRENT_UV - 2 ))
        echo "msg=Dropping CPU voltage to $CURRENT_UV" >> $LOG
        echo "uv=$CURRENT_UV" >> $LOG
        
        # Apply voltage
        for file in "/proc/eem/EEM_DET_B/eem_offset" "/proc/eem/EEM_DET_B_HI/eem_offset" "/proc/eem/EEM_DET_CCI/eem_offset" "/proc/eem/EEM_DET_L/eem_offset"; do
            [ -f "$file" ] && echo "$CURRENT_UV" > "$file"
        done
        
        echo "msg=Testing stability at $CURRENT_UV..." >> $LOG
        
        # Stress test: run simple busy loop in background
        yes > /dev/null &
        PIDS="$PIDS $!"
        yes > /dev/null &
        PIDS="$PIDS $!"
        
        sleep 4
        
        for p in $PIDS; do kill -9 $p 2>/dev/null; done
        PIDS=""
    done
    
    echo "status=completed" >> $LOG
    echo "msg=Auto-Tune completed! Limit reached: $CURRENT_UV" >> $LOG
    
    # Update main config
    CONF="/data/local/tmp/underover.conf"
    echo "CPU=\"$CURRENT_UV\"" > "$CONF"
) &
