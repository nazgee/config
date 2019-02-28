#!/bin/bash

_out=$1

fastboot flash system_b $_out/system.img
fastboot flash userdata $_out/userdata.img
fastboot flash vendor_a $_out/vendor.img
fastboot flash vendor_b $_out/vendor.img
fastboot flash persist $_out/persist.img
fastboot -w
