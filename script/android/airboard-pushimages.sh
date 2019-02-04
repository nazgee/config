#!/bin/bash

fastboot flash system_b system.img
fastboot flash userdata userdata.img
fastboot flash vendor_b vendor.img
fastboot flash persist persist.img
fastboot -w
