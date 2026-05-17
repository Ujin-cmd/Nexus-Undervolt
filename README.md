<div align="center">

```text
 █▄░█ █▀▀ ▀▄▀ █░█ █▀ 
 █░▀█ ██▄ █░█ █▄█ ▄█ 
 KERNEL MODULATION MATRIX
==========================
    [ REVISION 3.0 ]
```

**[ ROOT ACCESS REQUIRED ]** • **[ MAGISK MODULE ]** • **[ EEM TELEMETRY ]**

<br>

![Interface Mockup Preview](https://img.shields.io/badge/UI_STATUS-ONLINE-00ff88?style=for-the-badge)
![EEM Nodes Status](https://img.shields.io/badge/EEM_NODES-CONNECTED-00e5ff?style=for-the-badge)
![Target SoC](https://img.shields.io/badge/TARGET-MEDIATEK_%7C_SNAPDRAGON-ff3366?style=for-the-badge)

<br>
</div>

## `>` SYSTEM_OVERVIEW
**NEXUS** is not just an undervolting script; it is a highly advanced, neural-aesthetic web subsystem packaged as a Magisk Module. Operating entirely offline through `Magisk HTTPD`, it hooks directly into your kernel's `EEM` (Energy Estimation Module) domains and `cpufreq` nodes to push power efficiency to the bleeding edge.

---

## `>` INITIALIZING_MODULES

### `[0x01]` AI Auto-Tune Stratagem
Tired of soft-booting after pushing voltages too low?
NEXUS comes with a built-in background daemon that stress-tests the hardware while iteratively stepping down voltages by `-2` points per cycle.
* Automatically halts just before a kernel panic threshold.
* Device safe-guard mechanisms prevent bootloops.

### `[0x02]` Dynamic Hardware Enumeration
Supports multiple platforms without hardcoding. The installer dynamically scans `/proc/eem/` inside your kernel, mapping out your exact silicon topography:
* `EEM_DET_B` (Big Cores)
* `EEM_DET_L` (Little Cores)
* `EEM_DET_GPU` (Graphics)
* `EEM_DET_CCI` (Memory Interconnect)

### `[0x03]` Live Console & Telemetry
A cyber-hacker web dashboard at `http://127.0.0.1:8080` serves live:
* **Core Frequency** tracking
* **CPU / GPU Thermals** metrics 
* Immediate parameter injection console

### `[0x04]` Thermal Limit Extender
Bypass rigid OEM throttling configurations globally across all Thermal Zones `trip_points`. Keep your cores maxed safely up to `95°C` and set `Performance` or `Schedutil` governors on the fly from the UI.

---

## `>` DEPLOYMENT_CYCLE

To inject NEXUS into your Android infrastructure:
1. Download `Nexus_Undervolt_v3.0.zip` from the [Releases](../../releases) panel.
2. Flash through the **Magisk App** -> Modules -> Install from Storage.
3. Watch the cinematic ASCII initialization during flashing.
4. Reboot the host device.
5. Open any standard mobile browser and navigate to the uplink matrix:
   > **`http://127.0.0.1:8080`**

### `>` OTA_UPLINK
NEXUS seamlessly updates itself via Magisk tracking `update.json` in this repository.

<br>
<div align="center">
<i>"Why limit the hardware when we can modulate the matrix itself?"</i>
<br><br>
<img src="https://img.shields.io/badge/AUTHOR-UJIN-black?style=flat-square&logo=github">
</div>
