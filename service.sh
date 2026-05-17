#!/system/bin/sh
MODDIR=${0%/*}

# Wait until the device fully finishes booting
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

# Let the system stabilize for 40 seconds before applying under/over volting to avoid bootloops
sleep 40

# Apply the mountain mode and voltage offsets
sh $MODDIR/system/bin/underover_apply

# Start the Web UI on localhost:8080!
busybox httpd -p 127.0.0.1:8080 -h $MODDIR/web