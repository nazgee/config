#!/bin/bash

AIRBOARD=192.168.1.1
OVERLAY=$1
./obj/kernel/msm-4.14/arch/arm64/boot/dts/qcom/sa8155-vm.dtb
curl -T $OVERLAY/obj/kernel/msm-4.14/arch/arm64/boot/dts/qcom/sa8155-vm.dtb ftp://$AIRBOARD/vm/images --user root:
curl -T $OVERLAY/boot.img ftp://$AIRBOARD/vm/images/linux.img --user root:
curl -T $OVERLAY/ramdisk.img ftp://$AIRBOARD/vm/images/ramdisk.img --user root:
