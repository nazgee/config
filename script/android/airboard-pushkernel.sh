#!/bin/bash

AIRBOARD=192.168.1.115
OVERLAY=$1

ftp-upload --passive -h $AIRBOARD -u root -d /vm/images $OVERLAY/obj/kernel/msm-4.14/arch/arm64/boot/dts/qcom/sa8155-vm.dtb
#ftp-upload --passive -h $AIRBOARD -u root -d /vm/images --as linux-la.img $OVERLAY/obj/KERNEL_OBJ/arch/arm64/boot/Image
ftp-upload --passive -h $AIRBOARD -u root -d /vm/images --as linux-la.img $OVERLAY/linux.img
ftp-upload --passive -h $AIRBOARD -u root -d /vm/images $OVERLAY/ramdisk.img
#ftp-upload --passive -h $AIRBOARD -u root -d /vm/images --as ramdisk.img $OVERLAY/ramdisk-recovery.img
