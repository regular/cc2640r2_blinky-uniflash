# cc2640r2_blinky-uniflash
Baremetal blinky example for the TI CC2640R2 Launchpad. Makes uses of GCC, Make, and TI's uniflash ("dslite")

## Summary

This is an example project for the TI CC2640R2 Launchpad, designed to be built using standard tools.
Code Composer Studio (aka CCS) is not required to build, flash, or debug this project, i.e. it can all be done via the command line.

Uniflash however is required to flash. On Arch for example, you can get it via AUR.

## Dependencies

* `arm-none-eabi-gcc` with Cortex-M3 support. Any recent build, either from ARM or from your distro's official package repositories should work.
* The [TI CC2640R2 SDK](http://www.ti.com/tool/download/SIMPLELINK-CC2640R2-SDK) must be installed. Currently this is available only as a Windows
  installer, but the files can be installed via WINE and then copied elsewhere.
* TI Uniflash

## Building

1. Ensure the `CC2640_SDK` env var points to your installation of the SDK, for example:
  * `export CC2640_SDK="/opt/ti/simplelink_cc2640r2_sdk_1_50_00_58"`
2. If using a GCC installation that is not in your `$PATH`, modify `$CC2640_SDK/imports.mak` to point to the correct `GCC_ARMCOMPILER` location.
3. Run `make` in the project root.

## Known Issues

* The XDS110 debug adapter chip that comes on the Launchpad will need updated firmware for OpenOCD support. Otherwise, OpenOCD will refuse
  to connect to the adapter. Note that the easiest way to update the firmware is via Code Composer Studio's update tools.
* In order to connect to the XDS110 as a normal user, it is required to install udev rules to give the appropriate permissions. The CCS install 
  comes with a file that can be used to give permissions for TI devices, however its permissions are broader than needed for this project.
* The CC2640 support in OpenOCD is still in beta. A regular `monitor reset` command will cause the JTAG to lose connection, as will low-power modes
  on the CC2640. The `openocd.cfg` file remaps reset so that it does not issue a regular chip reset (see **Debugging**).
* The XDS110 USB support in Linux is not stable under VirtualBox. Often times the connection will be made, but die within ten seconds. The board must
  be power-cycled after this occurs.
* For additional caveats, please check TI's [official OpenOCD download page](http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/simplelink-openocd/latest/index_FDS.html).
* These scripts do not currently check if OpenOCD is running. If it is, you will have to kill it before running `make flash` to update the image.
​
