#!/system/bin/sh
MODDIR=${0%/*}

# Wait until the device fully finishes booting
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Let the system stabilize
sleep 15

# Apply undervolting
if [ -f "$MODDIR/system/bin/underover_apply" ]; then
    sh "$MODDIR/system/bin/underover_apply"
fi

# Start Web Server using Magisk's internal busybox
# Using port 8080. If you cannot access, try 'adb forward tcp:8080 tcp:8080'
# We remove the 127.0.0.1 binding by default to allow LAN access if needed, 
# but for security on public networks, 127.0.0.1 is safer. 
# Here we stick to 0.0.0.0 (default) but you can change to 127.0.0.1
# Added -f to keep it in a manageable process if needed, but backgrounded
/data/adb/magisk/busybox httpd -p 8080 -h "$MODDIR/web"