# LineageOS OTA setup for yunluo

[![Downloads](https://img.shields.io/github/downloads/xiaomi-mt6789-devs/releases/total?style=for-the-badge)](https://github.com/xiaomi-mt6789-devs/releases/releases)

This repo contains all stuff related to LineageOS OTA / Releases for yunluo

### 22/08/2024 - Updating readme.me to include missing install instructions. All credit to for the releases goes to Woomy of Belgium.

#### Installation

I was able to find the instructions here:

[https://web.archive.org/web/20240210151126/https://gitea.woomy.be/xiaomi-mt6789-devs/releases/wiki/Installation#expand](https://web.archive.org/web/20240210151126/https://gitea.woomy.be/xiaomi-mt6789-devs/releases/wiki/Installation#expand)

### Requirements

- A computer with recent Android Platform Tools installed (33.0.3 or newer)
- A Redmi Pad (yunluo) with an unlocked bootloader
- Firmware required by your ROM (#Firmware)

### Notes

- Lineage Recovery is the ONLY SUPPORTED recovery
- Custom kernels are NOT SUPPORTED

### Firmware
You need to install MIUI V14.0.2.0.TLYMIXM or V14.0.3.0.TLYMIXM (Global) firmware before installing the ROM.

### Booting the recovery

- Reboot your tablet into bootloader fastboot mode (using Volume Down Key or adb reboot bootloader)
- Flash the provided boot image using fastboot flash boot boot.img
- Flash the provided vendor_boot image using fastboot flash vendor_boot vendor_boot.img
- Reboot your tablet using fastboot reboot and hold the Volume Up until you see the recovery screen

**DON'T USE fastboot reboot recovery, it CAN result in a brick if there's a problem booting the recovery.**

### Flashing the ROM

- Start by formatting your /data partition

THIS WILL ERASE ALL YOUR DATA INCLUDING YOUR INTERNAL STORAGE
Go to Factory Reset -> Format data in the Lineage Recovery using Volume keys

### Next, sideload the rom

- Go to Apply Update > From ADB in the Lineage Recovery using Volume Keys
- On your PC, type adb sideload <path to rom.zip> (without the <>) (You can safely Ignore any "Signature verification failed" errors and select "Yes")
- If the recovery asks for rebooting to install additional packages, select NO
- If everything went fine, reboot to your new LineageOS installation using Reboot System in LineageOS Recovery

If you want to install Google Apps, you may need to wait for LineageOS to boot completely, then reboot to recovery, format d ata and flash the Gapps zip using adb sideload
