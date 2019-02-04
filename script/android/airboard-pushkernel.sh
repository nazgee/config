#!/bin/bash

AIRBOARD=192.168.1.1
OVERLAY=$1

ftp-upload --passive -h $AIRBOARD -u root -d /vm/images $OVERLAY/obj/kernel/msm-4.14/arch/arm64/boot/dts/qcom/sa8155-vm.dtb
ftp-upload --passive -h $AIRBOARD -u root -d /vm/images --as linux.img $OVERLAY/boot.img
ftp-upload --passive -h $AIRBOARD -u root -d /vm/images $OVERLAY/ramdisk.img
