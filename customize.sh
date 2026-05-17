#!/system/bin/sh

ui_print " "
ui_print " █▄░█ █▀▀ ▀▄▀ █░█ █▀ "
ui_print " █░▀█ ██▄ █░█ █▄█ ▄█ "
ui_print "  KERNEL MODULATION MATRIX  "
ui_print "---------------------------------------"
ui_print " "

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

[ -z "$SOC" ] && SOC="MediaTek Processing Unit"
SOC=$(echo "$SOC" | sed 's/mt/MT/g')

ui_print "[*] TARGET ARCHITECTURE: MEDIATEK"
sleep 0.2
ui_print "[*] SOC DETECTED: $SOC"
sleep 0.4
ui_print "[*] INITIALIZING NEURAL UPLINK..."
sleep 0.3
ui_print "[*] HANDSHAKE: ACCEPTED"
sleep 0.4

ui_print " "
ui_print "[*] TARGET HARDWARE: $SOC"
sleep 0.3
ui_print "[*] DEPLOYING EEM SCANNER PAYLOAD "

# Cinematic scanning animation
for i in 1 2 3 4; do
    ui_print "    [ SCANNING / ]"
    sleep 0.1
    ui_print "    [ SCANNING - ]"
    sleep 0.1
    ui_print "    [ SCANNING \ ]"
    sleep 0.1
done

ui_print " "
ui_print "[+] SCAN COMPLETE. ACQUIRED DOMAINS:"
sleep 0.2

EEM_COUNT=0
if [ -d "/proc/eem" ]; then
    for node in /proc/eem/*; do
        if [ -d "$node" ] && [ -f "$node/eem_offset" ]; then
            domain=$(basename "$node")
            # Create a fake hex code out of the name for cyberpunk flavor
            hex_id=$(echo -n "$domain" | md5sum | cut -c1-4)
            ui_print "    => [0x$hex_id] CORE_ONLINE: $domain"
            EEM_COUNT=$((EEM_COUNT+1))
            sleep 0.15
        fi
    done
fi

if [ "$EEM_COUNT" -eq 0 ]; then
    ui_print " "
    ui_print "[!] FATAL: NO EEM NODES DETECTED."
    ui_print "[!] KERNEL COMPATIBILITY: NEGATIVE."
    ui_print "ABORTING INSTALLATION."
    exit 1
fi

ui_print " "
ui_print "[+] INTEGRATING $EEM_COUNT ACTIVE DOMAINS."
sleep 0.5
ui_print "[+] FLASHING WEB APERTURE SUBSYSTEMS..."
sleep 0.4

ui_print " "
ui_print "======================================="
ui_print " SYSTEM CRITICAL: Thermal generation"
ui_print " will be eradicated. Access matrix at:"
ui_print "        http://127.0.0.1:8080         "
ui_print "======================================="
ui_print " "

# Apply execution permissions securely
set_perm_recursive "$MODPATH/web" 0 0 0755 0755
set_perm "$MODPATH/web/cgi-bin/apply.sh" 0 0 0755
set_perm "$MODPATH/web/cgi-bin/info.sh" 0 0 0755
set_perm "$MODPATH/web/cgi-bin/telemetry.sh" 0 0 0755
set_perm "$MODPATH/web/cgi-bin/auto_tune.sh" 0 0 0755
set_perm "$MODPATH/web/cgi-bin/tune_status.sh" 0 0 0755
set_perm "$MODPATH/system/bin/underover_apply" 0 0 0755
